resource_group_name = "jstart-all-dev-10302020" # "<resource_group_name>"

name                                = "acr10302020" # container_name
sku                                 = "Premium"     # SKU for container registry
georeplication_locations            = ["eastus"]    # list of geo-replicated azure locations
admin_enabled                       = true          # if(admin user is enabled) then set this to <true> otherwise <false>
private_endpoint_connection_enabled = true
assign_identity                     = true
enable_cmk                          = false

allowed_networks         = null # list of networks from which requests will match the netwrok rule
allowed_external_subnets = ["/subscriptions/9e9d8a58-6c9b-4cdb-8a7b-6450e36a6f51/resourceGroups/ADO-Base-Infrastructure/providers/Microsoft.Network/virtualNetworks/ADOBaseInfrastructurevnet649/subnets/testakspe"]

key_vault_resource_group = "ADO-Base-Infrastructure"
key_vault_name           = "ADO-Base-Infrastructure"
ado_subscription_id      = "9e9d8a58-6c9b-4cdb-8a7b-6450e36a6f51"

acr_additional_tags = {
  iac = "Terraform"
  env = "UAT"
}