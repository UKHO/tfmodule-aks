terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.36.0"
      configuration_aliases = [
        azurerm.spoke,
        azurerm.hub
      ]
    }
  }

  required_version = ">= 1.12.1"
}