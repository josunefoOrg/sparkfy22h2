terraform {
  required_version = ">=1.1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.96.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  subscription_id      = "ed29c799-3b06-4306-971a-202c3c2d29a9"
  tenant_id            = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  storage_account_name = "jojosparkstg"
  container_name       = "tfstate"
  key                  = "acr.tfstate"
  resource_group_name  = "spark-jojo-demo"
  features {}
}

locals {
  tags = {
    artifact_name   = "container-registry"
    product_version = "0.0.1"
  }
}
