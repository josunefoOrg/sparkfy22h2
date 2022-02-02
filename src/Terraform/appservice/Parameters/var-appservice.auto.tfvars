resource_group_name = "jstart-appservice-dev-09102020"
application_insights_name = "appsvc09102020"
ado_resource_group_name = "ADO-Base-Infrastructure" #set this to null if you don't want to use key vault secret in app settings
ado_key_vault_name          = "ADO-Base-Infrastructure" #set this to null if you don't want to use key vault secret in app settings
key_vault_secret_name   = null#"test" #set this to null if you don't want to use key vault secret in app settings
ado_subscription_id     = null
acr_secret_name         = null#"test"


app_services = {
  as1 = {
    name                 = "appservice-09102020"
    app_service_plan_key = "asp1"
    app_settings = {
       "WEBSITE_DNS_SERVER" = "168.63.129.16"
       "WEBSITE_VNET_ROUTE_ALL"= "1"
       "WEBSITE_PORT" = "80"
       "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
       #"DOCKER_REGISTRY_SERVER_URL"      = "https://appsvtest2020.azurecr.io"
       #"DOCKER_REGISTRY_SERVER_USERNAME" = "appsvtest2020"
    }
    client_affinity_enabled = null
    client_cert_enabled     = null
    enabled                 = null
    https_only              = null
    assign_identity         = true
    enable_monitoring       = false
    add_key_vault_secret    = false
    add_acr_password        = false
    auth_settings           = null
    storage_accounts        = null
    backup                  = {
      # name                = "backup01"
      # enabled             = true
      # storage_account_url = "https://appsvc09102020.blob.core.windows.net"
      # schedule            = {
      #   frequency_interval       = 1
      #   frequency_unit           = "Daily"
      #   keep_at_least_one_backup = true
      #   retention_period_in_days = 30
      #   start_time               = "13:00"
      #}
    }
    connection_strings      = null
    site_config = {
      always_on                        = null
      app_command_line                 = null
      default_documents                = null
      dotnet_framework_version         = null
      ftps_state                       = null
      http2_enabled                    = null
      java_version                     = null
      java_container                   = null
      java_container_version           = null
      local_mysql_enabled              = null
      linux_fx_version                 = null#"DOCKER|appsvtest2020.azurecr.io/sample/hello-world:v1"
      linux_fx_version_local_file_path = null
      windows_fx_version               = null
      managed_pipeline_mode            = null
      min_tls_version                  = null
      php_version                      = null
      python_version                   = null
      remote_debugging_enabled         = null
      remote_debugging_version         = null
      scm_type                         = null
      use_32_bit_worker_process        = null
      websockets_enabled               = null
      cors                             = null
      ip_restriction                   = null
    }
    logs = null
  }
}

app_service_plans = {
  asp1 = {
    name                         = "appsvcplan-09102020"
    kind                         = "Linux"
    reserved                     = true
    per_site_scaling             = false
    maximum_elastic_worker_count = 2
    sku_tier                     = "Premium"
    sku_size                     = "P1V2"
    sku_capacity                 = 1
  }
}

app_service_additional_tags = {
  iac = "Terraform"
  env = "UAT"
  pe_enable = true
}

vnet_swift_connection = {
  connection1 = {
    app_service_key = "as1"
    subnet_name      = "appservice" 
  }
}


app_service_slot = {
  slot1 = {
    name                 = "appsvcslot-09102020"
    app_service_plan_key = "asp1"
    app_service_key     = "as1"
}
}

appsvc_slot_vnet_integration = {
integration1 = {
   appsvc_slot_key  = "slot1" 
   app_service_key  = "as1"
   subnet_name      =  "appservice"
}
}

app_service_certificate = {
  # cert1 = {
  #  key_vault_secret_name = "appgwclientcert"
  #  certificate_name      = "appgwclientcert"
  #  app_service_key       = "as1" 
  # }
 }


custom_hostname_bindings = {
  # binding2 = {
  #  kv_cert_name = "appgwclientcert"
  #  hostname     = "testnew.azurewebsites.net"
  #  app_service_key = "as1"
  #  ssl_state       = "SniEnabled"
  # }
}

