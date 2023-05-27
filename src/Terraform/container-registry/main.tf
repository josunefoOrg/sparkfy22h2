terraform {
  required_version = ">=1.1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.96.0"
    }
  }
  backend "azurerm" {
    storage_account_name = "dnetcoreconfstg"
    container_name       = "tfstate"
    key                  = "acr.tfstate"
    resource_group_name  = "netcoreconf-demo"
  }
}

provider "azurerm" {
  subscription_id = "4572a41c-c128-4e47-bbbc-19d1a188492d"
  tenant_id       = "16b3c013-d300-468d-ac64-7eda0820b6d3"
  features {}
}

locals {
  tags = {
    artifact_name   = "container-registry"
    product_version = "0.0.1"
  }
}
