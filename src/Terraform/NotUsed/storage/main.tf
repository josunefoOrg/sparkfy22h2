data "azurerm_resource_group" "this" {
  count = local.resourcegroup_state_exists == false ? 1 : 0
  name  = var.resource_group_name
}

data "azurerm_key_vault" "this" {
  count               = (var.persist_access_key == true && local.keyvault_state_exists == false) ? 1 : 0
  name                = var.key_vault_name
  resource_group_name = local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name
}

# -
# - Get the current user config
# -
data "azurerm_client_config" "current" {}

locals {
  tags                       = merge((local.resourcegroup_state_exists == true ? lookup(data.terraform_remote_state.resourcegroup.outputs.resource_group_tags_map, var.resource_group_name) : data.azurerm_resource_group.this.0.tags), var.sa_additional_tags)
  resourcegroup_state_exists = length(values(data.terraform_remote_state.resourcegroup.outputs)) == 0 ? false : true
  keyvault_state_exists      = length(values(data.terraform_remote_state.keyvault.outputs)) == 0 ? false : true

  default_network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  disable_network_rules = {
    bypass                     = ["None"]
    default_action             = "Allow"
    ip_rules                   = null
    virtual_network_subnet_ids = null
  }

  blobs = {
    for b in var.blobs : b.name => merge({
      type         = "Block"
      size         = 0
      content_type = "application/octet-stream"
      source_file  = null
      source_uri   = null
      metadata     = {}
    }, b)
  }

  key_permissions         = ["get", "wrapkey", "unwrapkey"]
  secret_permissions      = ["get"]
  certificate_permissions = ["get"]
  storage_permissions     = ["get"]
}

# -
# - Storage Account
# -
resource "azurerm_storage_account" "this" {
  for_each                  = var.storage_accounts
  name                      = each.value["name"]
  resource_group_name       = local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name
  location                  = local.resourcegroup_state_exists == true ? lookup(data.terraform_remote_state.resourcegroup.outputs.resource_group_locations_map, var.resource_group_name) : data.azurerm_resource_group.this.0.location
  account_tier              = coalesce(lookup(each.value, "account_kind"), "StorageV2") == "FileStorage" ? "Premium" : split("_", each.value["sku"])[0]
  account_replication_type  = coalesce(lookup(each.value, "account_kind"), "StorageV2") == "FileStorage" ? "LRS" : split("_", each.value["sku"])[1]
  account_kind              = coalesce(lookup(each.value, "account_kind"), "StorageV2")
  access_tier               = lookup(each.value, "access_tier", null)
  enable_https_traffic_only = true 

  min_tls_version          = lookup(each.value, "min_tls_version", "TLS1_2")
  large_file_share_enabled = coalesce(each.value.large_file_share_enabled, false)

  
  dynamic "identity" {
    for_each = coalesce(lookup(each.value, "assign_identity"), false) == false ? [] : list(lookup(each.value, "assign_identity", false))
    content {
      type = "SystemAssigned"
    }
  }

  
  dynamic "network_rules" {
    for_each = lookup(each.value, "network_rules", null) != null ? [merge(local.default_network_rules, lookup(each.value, "network_rules", null))] : [local.default_network_rules]
    content {
      bypass                     = network_rules.value.bypass
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  tags = local.tags
}

# -
# - Store Storage Account Access Key to Key Vault Secrets
# -
resource "azurerm_key_vault_secret" "this" {
  for_each     = var.persist_access_key == true ? var.storage_accounts : {}
  name         = "${each.value["name"]}-access-key"
  value        = lookup(lookup(azurerm_storage_account.this, each.key), "primary_access_key")
  key_vault_id = local.keyvault_state_exists == true ? data.terraform_remote_state.keyvault.outputs.key_vault_id : data.azurerm_key_vault.this.0.id
  depends_on   = [azurerm_storage_account.this, azurerm_key_vault_access_policy.this]
}

# -
# - Container
# -
resource "azurerm_storage_container" "this" {
  for_each              = var.containers
  name                  = each.value["name"]
  storage_account_name  = each.value["storage_account_name"]
  container_access_type = coalesce(lookup(each.value, "container_access_type"), "private")
  depends_on = [
    azurerm_storage_account.this,
    azurerm_private_endpoint.this,
    azurerm_private_dns_a_record.this
  ]
}

# -
# - Blob
# -
resource "azurerm_storage_blob" "this" {
  for_each               = local.blobs
  name                   = each.value["name"]
  storage_account_name   = each.value["storage_account_name"]
  storage_container_name = each.value["storage_container_name"]
  type                   = each.value["type"]
  size                   = lookup(each.value, "size", null)
  content_type           = lookup(each.value, "content_type", null)
  source_uri             = lookup(each.value, "source_uri", null)
  metadata               = lookup(each.value, "metadata", null)
  depends_on = [
    azurerm_storage_account.this,
    azurerm_storage_container.this,
    azurerm_private_endpoint.this,
    azurerm_private_dns_a_record.this
  ]
}

# -
# - Queue
# -
resource "azurerm_storage_queue" "this" {
  for_each             = var.queues
  name                 = each.value["name"]
  storage_account_name = each.value["storage_account_name"]
  depends_on = [
    azurerm_storage_account.this,
    azurerm_private_endpoint.this,
    azurerm_private_dns_a_record.this
  ]
}

# -
# - File Share
# -
resource "azurerm_storage_share" "this" {
  for_each             = var.file_shares
  name                 = each.value["name"]
  storage_account_name = each.value["storage_account_name"]
  quota                = coalesce(lookup(each.value, "quota"), 110)
  depends_on = [
    azurerm_storage_account.this,
    azurerm_private_endpoint.this,
    azurerm_private_dns_a_record.this
  ]
}

# -
# - Table
# -
resource "azurerm_storage_table" "this" {
  for_each             = var.tables
  name                 = each.value["name"]
  storage_account_name = each.value["storage_account_name"]
  depends_on = [
    azurerm_storage_account.this,
    azurerm_private_endpoint.this,
    azurerm_private_dns_a_record.this
  ]
}

# -
# - Create Key Vault Accesss Policy for SA MSI
# -
locals {
  sa_principal_ids = flatten([
    for x in azurerm_storage_account.this :
    [
      for y in x.identity :
      y.principal_id if y.principal_id != ""
    ] if length(keys(azurerm_storage_account.this)) > 0
  ])

  msi_enabled_storage_accounts = [
    for sa_k, sa_v in var.storage_accounts :
    sa_v if coalesce(lookup(sa_v, "assign_identity"), false) == true
  ]
}

resource "azurerm_key_vault_access_policy" "this" {
  count        = length(local.msi_enabled_storage_accounts) > 0 ? length(local.sa_principal_ids) : 0
  key_vault_id = local.keyvault_state_exists == true ? data.terraform_remote_state.keyvault.outputs.key_vault_id : data.azurerm_key_vault.this.0.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = element(local.sa_principal_ids, count.index)

  key_permissions         = local.key_permissions
  secret_permissions      = local.secret_permissions
  certificate_permissions = local.certificate_permissions
  storage_permissions     = local.storage_permissions

  depends_on = [azurerm_storage_account.this]
}

# -
# - Enabled Customer Managed Key Encryption for Storage Account
# -
locals {
  cmk_enabled_sa_ids = [
    for sa_k, sa_v in var.storage_accounts :
    azurerm_storage_account.this[sa_k].id if(coalesce(lookup(sa_v, "cmk_enable"), false) == true && length(keys(azurerm_storage_account.this)) > 0)
  ]
  cmk_enabled_sa_names = [
    for sa_k, sa_v in var.storage_accounts :
    azurerm_storage_account.this[sa_k].name if(coalesce(lookup(sa_v, "cmk_enable"), false) == true && length(keys(azurerm_storage_account.this)) > 0)
  ]
  cmk_enable_storage_accounts = [
    for sa_k, sa_v in var.storage_accounts :
    sa_k if(coalesce(lookup(sa_v, "cmk_enable"), false) == true)
  ]
}


resource "azurerm_key_vault_key" "this" {
  count        = length(local.cmk_enable_storage_accounts)
  name         = element(local.cmk_enabled_sa_names, count.index)
  key_vault_id = local.keyvault_state_exists == true ? data.terraform_remote_state.keyvault.outputs.key_vault_id : data.azurerm_key_vault.this.0.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  depends_on   = [azurerm_storage_account.this, azurerm_key_vault_access_policy.this]
}


resource "azurerm_storage_account_customer_managed_key" "this" {
  count              = length(local.cmk_enable_storage_accounts)
  storage_account_id = element(local.cmk_enabled_sa_ids, count.index)
  key_vault_id       = local.keyvault_state_exists == true ? data.terraform_remote_state.keyvault.outputs.key_vault_id : data.azurerm_key_vault.this.0.id
  key_name           = element(local.cmk_enabled_sa_names, count.index)
  key_version        = element(azurerm_key_vault_key.this.*.version, count.index)
  depends_on         = [azurerm_storage_account.this, azurerm_key_vault_key.this]
}

################################################################
# ADO Private Endpoints
################################################################
locals {
  sa_ids_map = { for sa in azurerm_storage_account.this : sa.name => sa.id }
}

# -	
# - ADO Private Endpoint for SA Blob, Queue, File Share and Table
# -	
data "azurerm_resource_group" "ado_rg" {
  provider = azurerm.ado
  count    = (length(values(var.ado_private_endpoints)) > 0) ? 1 : 0
  name     = var.ado_resource_group_name
}

data "azurerm_subnet" "ado_subnet" {
  provider             = azurerm.ado
  count                = (length(values(var.ado_private_endpoints)) > 0) ? 1 : 0
  name                 = var.ado_subnet_name
  virtual_network_name = var.ado_vnet_name
  resource_group_name  = data.azurerm_resource_group.ado_rg.0.name
}

resource "azurerm_private_endpoint" "this" {
  provider            = azurerm.ado
  for_each            = var.ado_private_endpoints
  name                = each.value["name"]
  location            = data.azurerm_resource_group.ado_rg.0.location
  resource_group_name = data.azurerm_resource_group.ado_rg.0.name
  subnet_id           = data.azurerm_subnet.ado_subnet.0.id

  private_service_connection {
    name                           = "${each.value["name"]}-connection"
    private_connection_resource_id = lookup(local.sa_ids_map, each.value["resource_name"], null)
    is_manual_connection           = false
    subresource_names              = lookup(each.value, "group_ids", null)
    request_message                = null
  }

  lifecycle {
    ignore_changes = [
      private_service_connection[0].private_connection_resource_id
    ]
  }

  tags = local.tags

  depends_on = [azurerm_storage_account.this]
}

resource "azurerm_private_dns_a_record" "this" {
  provider            = azurerm.ado
  for_each            = var.ado_private_endpoints
  name                = each.value["resource_name"]
  zone_name           = each.value["dns_zone_name"] # DNS Zone created in Agent	
  resource_group_name = data.azurerm_resource_group.ado_rg.0.name
  ttl                 = "300"
  records             = [azurerm_private_endpoint.this[each.key].private_service_connection[0].private_ip_address]
  depends_on          = [azurerm_private_endpoint.this]
}
