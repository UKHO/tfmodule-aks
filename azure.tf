terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      configuration_aliases = [
        azurerm.spoke,
        azurerm.hub
      ]
    }
  }
}