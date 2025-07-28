terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
      configuration_aliases = [
        azurerm.spoke,
        azurerm.hub
      ]
    }
  }

  required_version = "~> 1.12.2"
}

provider "azurerm" {
  # TODO - Remove
}