resource "azurerm_container_registry" "acr" {
  name                = var.resourceName
  resource_group_name = var.resourceGroup
  location            = "westeurope"
  sku                 = "Premiums"
  admin_enabled       = false

  tags = local.tags
}
