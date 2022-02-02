data "azurerm_resource_group" "this" {
  count = local.resourcegroup_state_exists == false ? 1 : 0
  name  = var.resource_group_name
}

resource "random_id" "this" {
  keepers = {
    rg = var.resource_group_name
  }
  byte_length = 5
}

locals {
  default_network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  disable_network_acls = {
    bypass                     = "None"
    default_action             = "Allow"
    ip_rules                   = null
    virtual_network_subnet_ids = null
  }

  merged_network_acls = var.network_acls != null ? merge(local.default_network_acls, var.network_acls) : null

  tags                       = merge(var.kv_additional_tags, (local.resourcegroup_state_exists == true ? lookup(data.terraform_remote_state.resourcegroup.outputs.resource_group_tags_map, var.resource_group_name) : data.azurerm_resource_group.this.0.tags))
  resourcegroup_state_exists = length(values(data.terraform_remote_state.resourcegroup.outputs)) == 0 ? false : true
}

# -
# - Get the current user config
# -
data "azurerm_client_config" "current" {}

# -
# - Setup key vault 
# -
resource "azurerm_key_vault" "this" {
  name                = terraform.workspace == "demo" && var.name == "" ? substr("demo${random_id.this.hex}kv", 0, 23) : var.name
  resource_group_name = local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name
  location            = local.resourcegroup_state_exists == true ? lookup(data.terraform_remote_state.resourcegroup.outputs.resource_group_locations_map, var.resource_group_name) : data.azurerm_resource_group.this.0.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_enabled             = var.soft_delete_enabled
  purge_protection_enabled        = terraform.workspace == "demo" && var.name == "" ? false : var.purge_protection_enabled

  sku_name = var.sku_name

  dynamic "network_acls" {
    for_each = local.merged_network_acls == null ? [local.default_network_acls] : [local.merged_network_acls]
    content {
      bypass                     = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  tags = local.tags
}

# -
# - Add Key Vault Secrets
# -
resource "azurerm_key_vault_secret" "this" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_key_vault_access_policy.this]
}

# -
# - Key Vault Access Policy
# - Grant the current user Access to the Key Vault
# -
data "azuread_group" "this" {
  count = length(local.group_names)
  name  = local.group_names[count.index]
}

data "azuread_user" "this" {
  count               = length(local.user_principal_names)
  user_principal_name = local.user_principal_names[count.index]
}

locals {
  key_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore",
    "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge"
  ]
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
  ]
  certificate_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts",
    "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"
  ]
  storage_permissions = [
    "backup", "delete", "deletesas", "get", "getsas", "list", "listsas", "purge", "recover", "regeneratekey",
    "restore", "set", "setsas", "update"
  ]

  access_policies_keys = {
    for access_policy_key, access_policy in var.access_policies :
    access_policy_key => keys(lookup(var.access_policies, access_policy_key))
  }
  access_policies = flatten([
    for access_policy_key, access_policy in var.access_policies : [
      {
        group_names             = contains(local.access_policies_keys[access_policy_key], "group_names") == true ? access_policy.group_names : []
        object_ids              = contains(local.access_policies_keys[access_policy_key], "object_ids") == true ? access_policy.object_ids : []
        user_principal_names    = contains(local.access_policies_keys[access_policy_key], "user_principal_names") == true ? access_policy.user_principal_names : []
        certificate_permissions = contains(local.access_policies_keys[access_policy_key], "certificate_permissions") == true ? access_policy.certificate_permissions : []
        key_permissions         = contains(local.access_policies_keys[access_policy_key], "key_permissions") == true ? access_policy.key_permissions : []
        secret_permissions      = contains(local.access_policies_keys[access_policy_key], "secret_permissions") == true ? access_policy.secret_permissions : []
        storage_permissions     = contains(local.access_policies_keys[access_policy_key], "storage_permissions") == true ? access_policy.storage_permissions : []
      }
    ]
  ])

  group_names          = distinct(flatten(local.access_policies[*].group_names))
  user_principal_names = distinct(flatten(local.access_policies[*].user_principal_names))

  group_object_ids = { for g in data.azuread_group.this : lower(g.name) => g.id }
  user_object_ids  = { for u in data.azuread_user.this : lower(u.user_principal_name) => u.id }

  flattened_access_policies = concat(
    flatten([
      for p in local.access_policies : flatten([
        for i in p.object_ids : {
          object_id               = i
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.group_names : {
          object_id               = local.group_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.user_principal_names : {
          object_id               = local.user_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ])
  )

  grouped_access_policies = { for p in local.flattened_access_policies : p.object_id => p... }
  combined_access_policies = merge(
    {
      for k, v in local.grouped_access_policies :
      k => {
        object_id               = k
        certificate_permissions = distinct(flatten(v[*].certificate_permissions))
        key_permissions         = distinct(flatten(v[*].key_permissions))
        secret_permissions      = distinct(flatten(v[*].secret_permissions))
        storage_permissions     = distinct(flatten(v[*].storage_permissions))
      }
    },
    {
      self_permissions = {
        object_id               = var.msi_object_id
        certificate_permissions = local.certificate_permissions
        key_permissions         = local.key_permissions
        secret_permissions      = local.secret_permissions
        storage_permissions     = local.storage_permissions
      }
    }
  )
}

resource "azurerm_key_vault_access_policy" "this" {
  for_each     = local.combined_access_policies
  depends_on   = [azurerm_key_vault.this]
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = lookup(each.value, "object_id", null)

  key_permissions         = lookup(each.value, "key_permissions", null)
  secret_permissions      = lookup(each.value, "secret_permissions", null)
  certificate_permissions = lookup(each.value, "certificate_permissions", null)
  storage_permissions     = lookup(each.value, "storage_permissions", null)
}
