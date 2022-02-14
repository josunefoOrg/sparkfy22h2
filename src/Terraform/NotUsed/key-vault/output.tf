output "name" {
  value       = azurerm_key_vault.akv.name
  description = "Name of the created resource"
}
output "resourceId" {
  value       = azurerm_key_vault.akv.id
  description = "Id of the created resource"
}
output "resourceGroup" {
  value       = azurerm_key_vault.akv.resource_group_name
  description = "Resource Group Name of the created resource"
}
output "vaultUri" {
  value       = azurerm_key_vault.akv.vault_uri
  description = "URI to connect to the vault"
}
