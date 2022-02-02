variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the App Services."
}

variable "app_service_additional_tags" {
  type        = map(string)
  description = "Additional tags for the App Service resources, in addition to the resource group tags."
  default     = {}
}

# -
# - App Service Plans
# -
variable "app_service_plans" {
  type = map(object({
    name                         = string
    kind                         = string
    reserved                     = bool
    per_site_scaling             = bool
    maximum_elastic_worker_count = number
    sku_tier                     = string
    sku_size                     = string
    sku_capacity                 = number
  }))
  description = "The App Services plans with their properties."
  default     = {}
}

variable "existing_app_service_plans" {
  type = map(object({
    name                = string
    resource_group_name = string
  }))
  description = "Existing App Services plans."
  default     = {}
}

# -
# - App Services
# -
variable "app_services" {
  type = map(object({
    name                    = string
    app_service_plan_key    = string
    app_settings            = map(string)
    client_affinity_enabled = bool
    client_cert_enabled     = bool
    enabled                 = bool
    https_only              = bool
    assign_identity         = bool
    enable_monitoring       = bool
    add_key_vault_secret    = bool
    add_acr_password        = bool
    auth_settings = object({
      enabled                        = bool
      additional_login_params        = map(string)
      allowed_external_redirect_urls = list(string)
      default_provider               = string
      issuer                         = string
      runtime_version                = string
      token_refresh_extension_hours  = number
      token_store_enabled            = bool
      unauthenticated_client_action  = string
    })
    storage_accounts = list(object({
      name         = string
      type         = string
      account_name = string
      share_name   = string
      access_key   = string
      mount_path   = string
    }))
    backup = object({
      name                 = string
      enabled              = bool
      storage_account_name = string
      container_name       = string
      schedule = object({
        frequency_interval       = number
        frequency_unit           = string
        keep_at_least_one_backup = bool
        retention_period_in_days = number
        start_time               = string
      })
    })
    connection_strings = list(object({
      name  = string
      type  = string
      value = string
    }))
    site_config = object({
      always_on                        = bool
      app_command_line                 = string
      default_documents                = list(string)
      dotnet_framework_version         = string
      ftps_state                       = string
      http2_enabled                    = bool
      java_version                     = string
      java_container                   = string
      java_container_version           = string
      local_mysql_enabled              = bool
      linux_fx_version                 = string
      linux_fx_version_local_file_path = string
      windows_fx_version               = string
      managed_pipeline_mode            = string
      min_tls_version                  = string
      php_version                      = string
      python_version                   = string
      remote_debugging_enabled         = bool
      remote_debugging_version         = string
      scm_type                         = string
      use_32_bit_worker_process        = bool
      websockets_enabled               = bool
      cors = object({
        allowed_origins     = list(string)
        support_credentials = bool
      })
      ip_restriction = list(object({
        ip_address  = string
        subnet_name = string
      }))
    })
    logs = object({
      application_logs = object({
        azure_blob_storage = object({
          level                = string
          storage_account_name = string
          container_name       = string
          retention_in_days    = number
        })
      })
      http_logs = object({
        file_system = object({
          retention_in_days = number
          retention_in_mb   = number
        })
        azure_blob_storage = object({
          storage_account_name = string
          container_name       = string
          retention_in_days    = number
        })
      })
    })
  }))
  description = "The App Services with their properties."
  default     = {}
}

variable "application_insights_name" {
  type        = string
  description = "Specifies the Application Insights Name to collect application monitoring data"
  default     = null
}

variable "ado_resource_group_name" {
  description = "resource group name of the ado "
  default     = null
}

variable "ado_subscription_id" {
  description = "subscription id in which key vault exist"
}

variable "ado_key_vault_name" {
  description = "name of the key vault"
  default     = null
}

variable "key_vault_secret_name" {
  description = "name of the key vault secret"
  default     = null
}

variable "acr_secret_name" {
  description = "key vault secret name of ACR Password"
  default     = null
}

variable "vnet_swift_connection" {
  type = map(object({
    app_service_key           = string
    subnet_name               = string
    vnet_name                 = string
    networking_resource_group = string
  }))
  default = {}
}

variable "custom_hostname_bindings" {
  type = map(object({
    kv_cert_name    = string
    hostname        = string
    app_service_key = string
    ssl_state       = string
  }))
  default = {}
}

variable "app_service_slot" {
  type = map(object({
    name                 = string
    app_service_key      = string
    app_service_plan_key = string
  }))
  default = {}
}

variable "appsvc_slot_vnet_integration" {
  type = map(object({
    appsvc_slot_key           = string
    app_service_key           = string
    subnet_name               = string
    vnet_name                 = string
    networking_resource_group = string
  }))
}

variable "app_service_certificate" {
  type = map(object({
    key_vault_secret_name = string
    certificate_name      = string
    app_service_key       = string
  }))
  default = {}
}

############################
# State File
############################ 
variable ackey {
  description = "Not required if MSI is used to authenticate to the SA where state file is"
  default     = null
}
