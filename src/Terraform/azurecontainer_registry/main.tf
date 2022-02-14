data "azurerm_resource_group" "this" {
  count = local.resourcegroup_state_exists == false ? 1 : 0
  name  = var.resource_group_name
}

data "azurerm_subnet" "this" {
  for_each             = (var.private_endpoint_connection_enabled == true && var.allowed_networks != null && local.networking_state_exists == false) ? { for x in var.allowed_networks : format("%s_%s", x.subnet_name, x.vnet_name) => x } : {}
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name
}

data "azurerm_key_vault" "this" {
  count               = var.enable_cmk ? 1 : 0
  provider            = azurerm.ado
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group
}

# -
# - Get the current user config
# -
data "azurerm_client_config" "current" {}

locals {
  tags                       = merge(var.acr_additional_tags, (local.resourcegroup_state_exists == true ? lookup(data.terraform_remote_state.resourcegroup.outputs.resource_group_tags_map, var.resource_group_name) : data.azurerm_resource_group.this.0.tags))
  resourcegroup_state_exists = length(values(data.terraform_remote_state.resourcegroup.outputs)) == 0 ? false : true
  networking_state_exists    = length(values(data.terraform_remote_state.networking.outputs)) == 0 ? false : true

  subnet_ids = { for x in data.azurerm_subnet.this : x.name => x.id }

  external_subnet_ids = [
    for subnet in coalesce(var.allowed_external_subnets, []) : {
      action    = "Allow",
      subnet_id = subnet
    }
  ]

  default_network_rule_set = {
    default_action = "Deny"
    allowed_virtual_networks = [
      for network in coalesce(var.allowed_networks, []) : {
        action    = "Allow",
        subnet_id = local.networking_state_exists == true ? lookup(data.terraform_remote_state.networking.outputs.map_subnets_serviceendpoints, network.subnet_name) : lookup(local.subnet_ids, network.subnet_name)
      }
    ]
  }

  disable_network_rule_set = {
    default_action           = "Allow"
    allowed_virtual_networks = null
  }

  network_rule_set = var.private_endpoint_connection_enabled == true ? local.default_network_rule_set : local.disable_network_rule_set
}

# -
# - Azure Container Registry
# -
resource "azurerm_container_registry" "this" {
  count               = var.enable_cmk == false ? 1 : 0
  name                = var.name
  resource_group_name = local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name
  location            = local.resourcegroup_state_exists == true ? lookup(data.terraform_remote_state.resourcegroup.outputs.resource_group_locations_map, var.resource_group_name) : data.azurerm_resource_group.this.0.location

  sku                      = coalesce(var.sku, "Premium")
  admin_enabled            = coalesce(var.admin_enabled, false)
  georeplication_locations = var.georeplication_locations

  network_rule_set {
    default_action  = local.network_rule_set.default_action
    virtual_network = local.network_rule_set.allowed_virtual_networks
  }

  tags = local.tags
}

# -
# - Enable MSI In ACR
# -
resource "null_resource" "this" {
  count = (var.enable_cmk == false && coalesce(var.assign_identity, true) == true) ? 1 : 0

  triggers = {
    registry_id     = azurerm_container_registry.this.0.id
    assign_identity = var.assign_identity
  }
  provisioner "local-exec" {
    command = "az acr identity assign --identities [system] --name ${azurerm_container_registry.this.0.name}"
  }

  depends_on = [azurerm_container_registry.this]
}

# -
# - Create a user-assigned managed identity 
# -
resource "azurerm_user_assigned_identity" "this" {
  count               = var.enable_cmk ? 1 : 0
  resource_group_name = local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name
  location            = local.resourcegroup_state_exists == true ? lookup(data.terraform_remote_state.resourcegroup.outputs.resource_group_locations_map, var.resource_group_name) : data.azurerm_resource_group.this.0.location
  name                = var.name
}

# -
# - Create Key Vault Access Policy for UserManagedIdentity
# -
resource "azurerm_key_vault_access_policy" "this" {
  count        = var.enable_cmk ? 1 : 0
  key_vault_id = data.azurerm_key_vault.this.0.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.this.0.principal_id

  key_permissions = ["get", "unwrapKey", "wrapKey"]

  depends_on = [azurerm_user_assigned_identity.this]
}

# -
# - Assigning the "Key Vault Crypto Service Encryption" role to the UserManagedIdentity to access the key vault.
# -
resource "azurerm_role_assignment" "this" {
  count                            = var.enable_cmk ? 1 : 0
  scope                            = data.azurerm_key_vault.this.0.id
  role_definition_name             = "Key Vault Crypto Service Encryption (preview)"
  principal_id                     = azurerm_user_assigned_identity.this.0.principal_id
  skip_service_principal_aad_check = true
  depends_on                       = [azurerm_user_assigned_identity.this]
}

# -
# - Generate CMK Key for Azure Container Registry
# - 
resource "azurerm_key_vault_key" "this" {
  count        = var.enable_cmk ? 1 : 0
  name         = format("%s-key", var.name)
  key_vault_id = data.azurerm_key_vault.this.0.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt", "encrypt", "sign",
    "unwrapKey", "verify", "wrapKey"
  ]
}

# -
# - Create Azure Container Registry, enable MSI and the customer-managed key
# -
resource "null_resource" "cmk" {
  count = var.enable_cmk ? 1 : 0

  triggers = {
    user_managed_identity_id = azurerm_user_assigned_identity.this.0.id
    cmk_key_id               = azurerm_key_vault_key.this.0.id
  }
  provisioner "local-exec" {
    command = file("${path.module}/acr.sh")

    environment = {
      resourceGroupName             = local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name
      registryName                  = var.name
      sku                           = coalesce(var.sku, "Premium")
      adminEnabled                  = coalesce(var.admin_enabled, false)
      defaultAction                 = local.network_rule_set.default_action
      enableSystemIdentity          = coalesce(var.assign_identity, true)
      userAssignedManagedIdentityId = azurerm_user_assigned_identity.this.0.id
      customerManagedKeyId          = azurerm_key_vault_key.this.0.id
    }
  }

  depends_on = [
    azurerm_key_vault_key.this, azurerm_role_assignment.this,
    azurerm_key_vault_access_policy.this, azurerm_user_assigned_identity.this
  ]
}

# -
# - Create a replicated region for an Azure Container Registry
# -
resource "null_resource" "replication" {
  count = var.enable_cmk ? length(coalesce(var.georeplication_locations, [])) : 0

  triggers = {
    user_managed_identity_id = azurerm_user_assigned_identity.this.0.id
    cmk_key_id               = azurerm_key_vault_key.this.0.id
  }
  provisioner "local-exec" {
    command = "az acr replication create --location ${element(var.georeplication_locations, count.index)} --registry ${var.name} --resource-group ${local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name}"
  }

  depends_on = [null_resource.cmk]
}

# -
# - Add a network rule to Azure Container Registry
# -
resource "null_resource" "network_rule" {
  count = var.enable_cmk ? length(concat(local.network_rule_set.allowed_virtual_networks, local.external_subnet_ids)) : 0

  triggers = {
    user_managed_identity_id = azurerm_user_assigned_identity.this.0.id
    cmk_key_id               = azurerm_key_vault_key.this.0.id
  }
  provisioner "local-exec" {
    command = "az acr network-rule add --name ${var.name} --subnet ${element(concat(local.network_rule_set.allowed_virtual_networks, local.external_subnet_ids), count.index)["subnet_id"]}"
  }

  depends_on = [null_resource.cmk]
}
