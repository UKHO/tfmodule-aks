locals {
    principal_id = var.principal_id != null ? var.principal_id : data.azurerm_client_config.current.object_id
}