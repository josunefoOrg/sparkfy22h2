# #############################################################################
# # OUTPUTS Azure Container Registry
# #############################################################################

data "azurerm_container_registry" "this" {
  count               = var.enable_cmk ? 1 : 0
  name                = var.name
  resource_group_name = local.resourcegroup_state_exists == true ? var.resource_group_name : data.azurerm_resource_group.this.0.name
  depends_on          = [null_resource.cmk, null_resource.replication, null_resource.network_rule]
}

output "acr_id" {
  description = "The Container Registry ID."
  value       = var.enable_cmk == false ? azurerm_container_registry.this.0.id : data.azurerm_container_registry.this.0.id
}

output "acr_name" {
  description = "The Container Registry name."
  value       = var.enable_cmk == false ? azurerm_container_registry.this.0.name : data.azurerm_container_registry.this.0.name
}

output "login_server" {
  description = "The URL that can be used to log into the container registry."
  value       = var.enable_cmk == false ? azurerm_container_registry.this.0.login_server : data.azurerm_container_registry.this.0.login_server
}

output "acr_fqdn" {
  description = "The Container Registry FQDN."
  value       = var.enable_cmk == false ? azurerm_container_registry.this.0.login_server : data.azurerm_container_registry.this.0.login_server
}

output "admin_username" {
  description = "The Username associated with the Container Registry Admin account - if the admin account is enabled."
  value       = var.enable_cmk == false ? azurerm_container_registry.this.0.admin_username : data.azurerm_container_registry.this.0.admin_username
}

output "admin_password" {
  description = "The Password associated with the Container Registry Admin account - if the admin account is enabled."
  value       = var.enable_cmk == false ? azurerm_container_registry.this.0.admin_password : data.azurerm_container_registry.this.0.admin_password
  sensitive   = true
}
