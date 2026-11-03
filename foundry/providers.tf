terraform {
  required_version = "~> 1.10"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.17, < 5.0"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {}
}
