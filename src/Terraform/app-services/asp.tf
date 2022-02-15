resource "azurerm_app_service_plan" "asp" {
  name                = var.aspResourceName
  location            = "westeurope"
  resource_group_name = var.resourceGroup
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }

  tags = local.tags
}
