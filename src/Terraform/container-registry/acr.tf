resource "azurerm_container_registry" "acr" {
  name                = var.resourceName
  resource_group_name = var.resourceGroup
  location            = "westeurope"
  sku                 = "Standard"
  admin_enabled       = false

  tags = local.tags
}
