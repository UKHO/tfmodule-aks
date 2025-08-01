module "private_endpoint" {
  source    = "github.com/UKHO/tfmodule-azure-private-endpoint-private-link?ref=0.7.0"
  providers = {
    azurerm.spoke = azurerm.spoke
    azurerm.hub   = azurerm.hub
  }

  private_connection          = [azurerm_kubernetes_cluster.this.id]
  pe_identity                 = [azurerm_kubernetes_cluster.this.name]
  pe_environment              = var.pe_environment
  pe_vnet_rg                  = var.vnet_resource_group_name
  pe_vnet_name                = var.vnet_name
  pe_subnet_name              = var.pe_subnet_name
  pe_resource_group           = [var.resource_group_name]
  pe_resource_group_locations = [var.location]
  dns_resource_group          = var.dns_resource_group_name
  dns_zone                    = "privatelink.uksouth.azmk8s.io"
  zone_group                  = "private-dns-zone-group"
  subresource_names           = ["management"]

  count = var.pe_enabled ? 1 : 0
}