# #############################################################################
# # OUTPUTS Key Vault
# #############################################################################

output "key_vault_id" {
  description = "The Id of the Key Vault"
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "The Name of the Key Vault"
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets"
  value       = azurerm_key_vault.this.vault_uri
}

output "key_vault" {
  description = "Key Vault details"
  value       = azurerm_key_vault.this
}

output "key_vault_policy" {
  description = "Key Vault access policy details"
  value       = azurerm_key_vault_access_policy.this
}

output "purge_protection" {
  description = "Key Vault purge protection status"
  value       = azurerm_key_vault.this.purge_protection_enabled
}
