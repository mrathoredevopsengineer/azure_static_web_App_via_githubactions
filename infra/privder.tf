terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    # Backend config will be provided via dev.backend.tf
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion            = true
      graceful_shutdown                      = false
      skip_shutdown_and_force_delete         = false
    }
  }
}
