resource "azurerm_kubernetes_cluster" "this" {
  provider                            = azurerm.spoke
  name                                = var.aks_name
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  kubernetes_version                  = var.aks_kubernetes_version
  azure_policy_enabled                = true
  http_application_routing_enabled    = false
  role_based_access_control_enabled   = true
  sku_tier                            = var.aks_sku
  workload_identity_enabled           = true
  oidc_issuer_enabled                 = true
  private_cluster_enabled             = var.pe_enabled
  dns_prefix                          = var.aks_name
  private_dns_zone_id                 = var.pe_enabled ? data.azurerm_private_dns_zone.aks.id : null

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "calico"
    pod_cidr            = "192.168.0.0/16"
  }

  dynamic "api_server_access_profile" {
    for_each = var.pe_enabled ? [] : ["apply"]

    content {
      authorized_ip_ranges = var.pe_enabled ? [] : var.ip_rules
    }
  }

  default_node_pool {
    name                        = "systempool"
    vm_size                     = var.aks_system_node_vm_size
    os_disk_size_gb             = var.aks_system_node_disk_size
    vnet_subnet_id              = data.azurerm_subnet.aks.id
    type                        = "VirtualMachineScaleSets"
    auto_scaling_enabled        = true
    min_count                   = var.aks_system_node_min_count
    max_count                   = var.aks_system_node_max_count
    temporary_name_for_rotation = "tmpnodepool"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  web_app_routing {
    dns_zone_ids             = []
    default_nginx_controller = "Internal"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.principal_id]
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  monitor_metrics { }

  storage_profile {
    blob_driver_enabled = true
  }

  lifecycle {
    ignore_changes = [tags, microsoft_defender]
  }

  depends_on = [ azurerm_role_assignment.aks_vnet_contributor ]
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each = { for i, s in var.user_node_pools : i => s }

  provider              = azurerm.spoke
  name                  = each.value.name
  vm_size               = each.value.vm_size
  vnet_subnet_id        = data.azurerm_subnet.aks.id
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  os_disk_size_gb       = each.value.disk_size
  auto_scaling_enabled  = true
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  node_count            = each.value.min_count
  os_type               = each.value.os_type
  priority              = var.aks_use_spot ? "Spot" : "Regular"
  spot_max_price        = var.aks_use_spot ? -1 : null
  eviction_policy       = var.aks_use_spot ? "Delete" : null

  lifecycle {
    ignore_changes = [node_count, node_taints, node_labels, upgrade_settings]
  }
}

# Identity

resource "azurerm_user_assigned_identity" "this" {
  provider            = azurerm.spoke
  location            = var.location
  name                = var.aks_name
  resource_group_name = var.resource_group_name
}

# Roles

resource "azurerm_role_assignment" "aks_vnet_contributor" {
  provider             = azurerm.spoke
  scope                = data.azurerm_virtual_network.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# TODO - We need to grant permissions to the pipeline SP (not the terraform SP), so that it can do helm deploys
# resource "azurerm_role_assignment" "pipeline_aks_cluster_admin" {
#   scope                = azurerm_kubernetes_cluster.this.id
#   role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
#   principal_id         = data.azurerm_client_config.current.object_id # TODO - Need to decide on how we name the pipeline_principal_id variable to differentiate it from var.principal_id
# }
