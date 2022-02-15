resource "azurerm_container_registry" "acr" {
  name                = var.acrResourceName
  resource_group_name = var.resourceGroup
  location            = "westeurope"
  sku                 = "Standard"
  admin_enabled       = false
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.umi.id
    ]
  }

  tags = local.tags
}
