variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure Container Registry."
}

variable "acr_additional_tags" {
  type        = map(string)
  description = "Additional tags for the Azure Container Registry resource, in addition to the resource group tags."
  default     = {}
}

# -
# - Azure Container Registry
# -
variable "name" {
  type        = string
  description = "Azure Container Registery Name"
}

variable "sku" {
  type        = string
  description = "Azure Container Registery SKU. Possible values are Basic, Standard and Premium."
  default     = "Premium"
}

variable "admin_enabled" {
  type        = bool
  description = "Specifies whether the admin user is enabled."
  default     = false
}

variable "georeplication_locations" {
  type        = list(string)
  description = "A list of Azure locations where the container registry should be geo-replicated."
  default     = []
}

variable "allowed_networks" {
  type = list(object({
    subnet_name = string
    vnet_name   = string
  }))
  description = "Specifies the list of netowrks from which requests will match the network rule."
  default     = null
}

variable "allowed_external_subnets" {
  type        = list(string)
  description = "Specifies the list of subnets from which requests will match the network rule."
  default     = []
}

variable "private_endpoint_connection_enabled" {
  type        = bool
  description = "Specifies whether the Private Endpoint Connection is enabled or not."
  default     = true
}

variable "assign_identity" {
  type        = bool
  description = "Specifies whether to enable Managed System Identity for the Azure Container Registry."
  default     = true
}

variable "enable_cmk" {
  type        = bool
  description = "Specifies whether to enable Customer Managed Identity for the Azure Container Registry."
  default     = false
}

variable "key_vault_resource_group" {
  type        = string
  description = "Specifies the Resource Group name where source Key Vault used for CMK exists"
  default     = null
}

variable "key_vault_name" {
  type        = string
  description = "Specifies the Key Vault name where CMK Keys exists"
  default     = null
}

variable "ado_subscription_id" {
  type        = string
  description = "Specifies the ado subscription id"
  default     = null
}

############################
# State File
############################ 
variable ackey {
  description = "Not required if MSI is used to authenticate to the SA where state file is"
  default     = null
}
