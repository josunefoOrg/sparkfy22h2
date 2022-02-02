variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the storage account"
}

variable "sa_additional_tags" {
  type        = map(string)
  description = "Tags of the SA in addition to the resource group tag."
  default = {
    pe_enable = true
  }
}

variable "storage_accounts" {
  type = map(object({
    name                     = string
    sku                      = string
    account_kind             = string
    access_tier              = string
    assign_identity          = bool
    cmk_enable               = bool
    min_tls_version          = string
    large_file_share_enabled = bool
    network_rules = object({
      bypass                     = list(string) # (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None.
      default_action             = string       # (Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny.
      ip_rules                   = list(string) # (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault.
      virtual_network_subnet_ids = list(string) # (Optional) One or more Subnet ID's which should be able to access this Key Vault.
    })
  }))
  description = "Map of storage accouts which needs to be created in a resource group"
  default     = {}
}

variable "persist_access_key" {
  type        = bool
  description = "Store Storage Account Primary Access Key to Key Vault?"
  default     = true
}

variable "key_vault_name" {
  type        = string
  description = "Specifies the existing Key Vault Name where you want to store Storage Account Primary Access Key."
  default     = null
}

variable "containers" {
  type = map(object({
    name                  = string
    storage_account_name  = string
    container_access_type = string
  }))
  description = "Map of Storage Containers"
  default     = {}
}

variable "blobs" {
  type = map(object({
    name                   = string
    storage_account_name   = string
    storage_container_name = string
    type                   = string
    size                   = number
    content_type           = string
    source_uri             = string
    metadata               = map(any)
  }))
  description = "Map of Storage Blobs"
  default     = {}
}

variable "queues" {
  type = map(object({
    name                 = string
    storage_account_name = string
  }))
  description = "Map of Storages Queues"
  default     = {}
}

variable "file_shares" {
  type = map(object({
    name                 = string
    storage_account_name = string
    quota                = number
  }))
  description = "Map of Storages File Shares"
  default     = {}
}

variable "tables" {
  type = map(object({
    name                 = string
    storage_account_name = string
  }))
  description = "Map of Storage Tables"
  default     = {}
}

# -
# - ADO Private Endpoints
# -
variable "ado_private_endpoints" {
  type = map(object({
    name          = string
    resource_name = string
    group_ids     = list(string)
    dns_zone_name = string
  }))
  description = "Map containing Private Endpoint and Private DNS Zone details"
  default     = {}
}

variable "ado_resource_group_name" {
  type        = string
  description = "Specifies the existing ado agent resource group name"
  default     = null
}

variable "ado_vnet_name" {
  type        = string
  description = "Specifies the existing ado agent virtual network name"
  default     = null
}

variable "ado_subnet_name" {
  type        = string
  description = "Specifies the existing ado agent subnet name"
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
