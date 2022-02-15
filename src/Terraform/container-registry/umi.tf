resource "azurerm_user_assigned_identity" "umi" {
  resource_group_name = var.resourceGroup
  location            = "westeurope"

  name = var.umiResourceName
}

resource "azurerm_role_assignment" "umiACRPull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.umi.principal_id
}
