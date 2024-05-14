terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.2"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }

  backend "azurerm" {
    resource_group_name  = "mmrv-staging-rg"
    storage_account_name = "mmrvstagingsa"
    container_name       = "mmrv-staging-sa"
    key                  = ".stg.mmrv.aks.tfstate"
    subscription_id      = ""
    tenant_id            = ""
    client_id            = ""
    client_secret        = ""
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
    subscription_id      = ""
    tenant_id            = ""
    client_id            = ""
    client_secret        = ""
}

