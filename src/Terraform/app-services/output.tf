output "aspName" {
  value       = azurerm_app_service_plan.asp.name
  description = "Name of the created resource"
}
output "aspResourceId" {
  value       = azurerm_app_service_plan.asp.id
  description = "Id of the created resource"
}
output "aasName" {
  value       = azurerm_app_service.aas.name
  description = "Name of the created resource"
}
output "aasResourceId" {
  value       = azurerm_app_service.aas.id
  description = "Id of the created resource"
}
output "resourceGroup" {
  value       = azurerm_app_service_plan.asp.resource_group_name
  description = "Resource Group Name of the created resource"
}
