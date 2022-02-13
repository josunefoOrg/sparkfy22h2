resource "azurerm_key_vault" "akv" {
  name                = var.resourceName
  location            = "westeurope"
  resource_group_name = var.resourceGroup
  tenant_id           = "72f988bf-86f1-41af-91ab-2d7cd011db47"

  sku_name                   = "standard"
  purge_protection_enabled   = false

  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true

#   network_acls {
#     default_action             = "Deny"
#     bypass                     = var.networkACLs.bypass
#     ip_rules                   = var.networkACLs.ipRules
#     virtual_network_subnet_ids = var.networkACLs.serviceEndpointSubnetIds
#   }

  tags = local.tags
}
