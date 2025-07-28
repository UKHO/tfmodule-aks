terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }

  required_version = ">= 1.12.1"
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}