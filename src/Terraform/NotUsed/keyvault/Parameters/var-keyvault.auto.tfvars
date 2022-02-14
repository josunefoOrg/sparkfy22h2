resource_group_name = "jstart-all-dev-08152020"

name                            = "jstartlayerall08152020kv"
enabled_for_deployment          = null
enabled_for_disk_encryption     = null
enabled_for_template_deployment = null
soft_delete_enabled             = true
purge_protection_enabled        = true
sku_name                        = "standard"
secrets                         = {}
access_policies                 = {}
network_acls                    = null

msi_object_id                   = "273de62b-feb5-40a8-882a-3028a3294e64"

kv_additional_tags = {
  pe_enable = true
  iac       = "Terraform"
  env       = "UAT"
}
