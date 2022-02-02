# --------------------------------------------------------
# Setup
# --------------------------------------------------------

# Provider block -> please make sure you have added partner id
provider "azurerm" {
  # Whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version         = "~> 2.31.1"
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  #client_id       = var.client_id
  #client_secret   = var.client_secret
  partner_id      = "a79fe048-6869-45ac-8683-7fd2446fc73c"

  features {}
}

# Provider block -> please make sure you have added partner id
# Provider to Non Production Environment
provider "azurerm" {
  # Whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version         = "~> 2.31.1"
  alias           = "ado"
  tenant_id       = var.tenant_id
  subscription_id = var.ado_subscription_id == null ? var.subscription_id : var.ado_subscription_id
  #client_id       = var.client_id
  #client_secret   = var.client_secret
  partner_id      = "a79fe048-6869-45ac-8683-7fd2446fc73c"

  features {}
}

# Azure AD Provider
provider "azuread" {
  version         = "0.8.0"
  subscription_id = var.subscription_id
  #client_id       = var.client_id
  #client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Set the terraform backend
terraform {
  required_version = "~> 0.12.20"
  backend "azurerm" {} #Backend variables are initialized through the secret and variable folders
}
