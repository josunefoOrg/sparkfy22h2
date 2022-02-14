# #############################################################################
# # OUTPUTS Storage Account
# #############################################################################

output "sa_names" {
  value = [for x in azurerm_storage_account.this : x.name]
}

output "sa_ids" {
  value = [for x in azurerm_storage_account.this : x.id]
}

output "sa_ids_map" {
  value = { for x in azurerm_storage_account.this : x.name => x.id }
}

output "primary_blob_endpoints" {
  value     = [for x in azurerm_storage_account.this : x.primary_blob_endpoint]
  sensitive = true
}

output "primary_blob_endpoints_map" {
  value     = { for x in azurerm_storage_account.this : x.name => x.primary_blob_endpoint }
  sensitive = true
}

output "primary_connection_strings" {
  value     = [for x in azurerm_storage_account.this : x.primary_connection_string]
  sensitive = true
}

output "primary_connection_strings_map" {
  value     = { for x in azurerm_storage_account.this : x.name => x.primary_connection_string }
  sensitive = true
}

output "primary_blob_connection_strings_map" {
  value     = { for x in azurerm_storage_account.this : x.name => x.primary_blob_connection_string }
  sensitive = true
}

output "primary_access_keys" {
  value     = [for x in azurerm_storage_account.this : x.primary_access_key]
  sensitive = true
}

output "primary_access_keys_map" {
  value     = { for x in azurerm_storage_account.this : x.name => x.primary_access_key }
  sensitive = true
}

output "container_ids" {
  value = [for c in azurerm_storage_container.this : c.id]
}

output "blob_ids" {
  value = [for b in azurerm_storage_blob.this : b.id]
}

output "blob_urls" {
  value = [for b in azurerm_storage_blob.this : b.url]
}

output "file_share_ids" {
  value = [for s in azurerm_storage_share.this : s.id]
}

output "file_share_urls" {
  value = [for s in azurerm_storage_share.this : s.url]
}
