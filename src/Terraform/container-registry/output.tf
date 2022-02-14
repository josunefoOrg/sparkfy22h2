output "name" {
  value       = azurerm_container_registry.acr.name
  description = "Name of the created resource"
}
output "resourceId" {
  value       = azurerm_container_registry.acr.id
  description = "Id of the created resource"
}
output "resourceGroup" {
  value       = azurerm_container_registry.acr.resource_group_name
  description = "Resource Group Name of the created resource"
}
output "loginServer" {
  value       = azurerm_container_registry.acr.login_server
  description = "URI to connect to the ACR"
}
