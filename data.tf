data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "this" {
  provider            = azurerm.spoke
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

data "azurerm_subnet" "aks" {
  provider             = azurerm.spoke
  name                 = var.aks_subnet_name
  virtual_network_name = data.azurerm_virtual_network.this.name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.uksouth.azmk8s.io"
  resource_group_name = var.dns_resource_group_name
}
