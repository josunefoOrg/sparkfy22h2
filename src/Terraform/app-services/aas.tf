resource "azurerm_app_service" "aas" {
  name                = var.aasResourceName
  location            = "westeurope"
  resource_group_name = var.resourceGroup
  app_service_plan_id = azurerm_app_service_plan.asp.id
  https_only          = false

  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.umi.id
    ]
  }
  site_config {
    http2_enabled                        = true
    acr_use_managed_identity_credentials = true
    acr_user_managed_identity_client_id  = data.azurerm_user_assigned_identity.umi.client_id

    always_on = "true"

    linux_fx_version = "DOCKER|${var.acrName}.azurecr.io/netcoreconf23acr/netcoreconf23ml:latest"
  }

  tags = local.tags
}
