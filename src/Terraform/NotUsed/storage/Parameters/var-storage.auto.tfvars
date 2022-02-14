resource_group_name = "jstart-vmss-layered07142020"

storage_accounts = {
  sa1 = {
    name                     = "jstartlayer08202020sa"
    sku                      = "Standard_LRS"
    account_kind             = null
    access_tier              = null
    assign_identity          = true
    cmk_enable               = true
    min_tls_version          = "TLS1_2"
    large_file_share_enabled = true
    network_rules            = null
  }
}

containers = {
  container1 = {
    name                  = "test"
    storage_account_name  = "jstartlayer08202020sa"
    container_access_type = "private"
  }
}

blobs = {
  blob1 = {
    name                   = "test"
    storage_account_name   = "jstartlayer08202020sa"
    storage_container_name = "test"
    type                   = "Block"
    size                   = null
    content_type           = null
    source_uri             = null
    metadata               = {}
  }
}

queues = {
  queue1 = {
    name                 = "test1"
    storage_account_name = "jstartlayer08202020sa"
  }
}

file_shares = {
  share1 = {
    name                 = "share1"
    storage_account_name = "jstartlayer08202020sa"
    quota                = "512"
  }
}

tables = {
  table1 = {
    name                 = "table1"
    storage_account_name = "jstartlayer08202020sa"
  }
}

ado_private_endpoints = {
  ape1 = {
    name          = "jstartlayer08202020sablob"
    resource_name = "jstartlayer08202020sa"
    group_ids     = ["blob"]
    dns_zone_name = "privatelink.blob.core.windows.net"
  },
  ape2 = {
    name          = "jstartlayer08202020safile"
    resource_name = "jstartlayer08202020sa"
    group_ids     = ["file"]
    dns_zone_name = "privatelink.file.core.windows.net"
  },
  ape3 = {
    name          = "jstartlayer08202020satable"
    resource_name = "jstartlayer08202020sa"
    group_ids     = ["table"]
    dns_zone_name = "privatelink.table.core.windows.net"
  },
  ape4 = {
    name          = "jstartlayer08202020saqueue"
    resource_name = "jstartlayer08202020sa"
    group_ids     = ["queue"]
    dns_zone_name = "privatelink.queue.core.windows.net"
  }
}

ado_resource_group_name = "ADO-Base-Infrastructure"
ado_vnet_name           = "ADOBaseInfrastructurevnet649"
ado_subnet_name         = "testakspe"
ado_subscription_id     = null

key_vault_name = null #"jstartall08202020kv"

sa_additional_tags = {
  iac       = "Terraform"
  env       = "UAT"
  pe_enable = true
}