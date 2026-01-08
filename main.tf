resource "azurerm_kubernetes_cluster" "this" {
  provider                            = azurerm.spoke
  name                                = var.aks_name
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  kubernetes_version                  = var.aks_kubernetes_version
  azure_policy_enabled                = true
  http_application_routing_enabled    = false
  role_based_access_control_enabled   = true
  local_account_disabled              = true
  sku_tier                            = var.aks_sku
  workload_identity_enabled           = true
  oidc_issuer_enabled                 = true
  private_cluster_enabled             = var.pe_enabled
  dns_prefix                          = var.aks_name
  private_dns_zone_id                 = var.pe_enabled ? "None" : null
  private_cluster_public_fqdn_enabled = var.pe_enabled

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "calico"
    pod_cidr            = "192.168.0.0/16"
  }

  api_server_access_profile {
    authorized_ip_ranges                = var.ip_rules
    subnet_id                           = length(var.kms_key_vault_id) > 0 && local.kms_network_access == "Private" ? var.api_server_subnet_id : null
    virtual_network_integration_enabled = length(var.kms_key_vault_id) > 0 && local.kms_network_access == "Private" ? true : null
  }

  dynamic "service_mesh_profile" {
    for_each = var.istio_enabled ? [1] : []

    content {
      mode = "Istio"
      revisions = var.istio_revisions
      internal_ingress_gateway_enabled = var.istio_internal_ingress_gateway_enabled
      external_ingress_gateway_enabled = var.istio_external_ingress_gateway_enabled

      dynamic "certificate_authority" {
        for_each = var.istio_certificate_authority_enabled ? [1] : []

        content {
          key_vault_id                = var.istio_ca_key_vault_id
          root_cert_object_name       = var.istio_ca_root_cert_object_name
          cert_chain_object_name      = var.istio_ca_cert_chain_object_name
          cert_object_name            = var.istio_ca_cert_object_name
          key_object_name             = var.istio_ca_key_object_name
        }
      }
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
    host_encryption_enabled     = true

    upgrade_settings {
      max_surge = "10%"
    }
  }

  dynamic "web_app_routing" {
    for_each = var.web_app_routing_enabled ? [1] : []

    content {
      dns_zone_ids             = []
      default_nginx_controller = "None"
    }
  }

  identity {
    type = length(var.kms_key_vault_id) > 0 && local.kms_network_access == "Private" ? "UserAssigned" : "SystemAssigned"
    identity_ids = length(var.kms_key_vault_id) > 0 && local.kms_network_access == "Private" ? [azurerm_user_assigned_identity.aks[0].id] : null
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  dynamic "key_management_service" {
    for_each = length(var.kms_key_vault_id) > 0 ? [1] : []

    content {
      key_vault_key_id         = local.kms_key_id
      key_vault_network_access = local.kms_network_access
    }
  }

  monitor_metrics { }

  storage_profile {
    blob_driver_enabled = true
  }

  lifecycle {
    ignore_changes = [tags, microsoft_defender]
  }

  depends_on = [
    azurerm_role_assignment.aks_subnet_network_contributor
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each = { for i, s in var.user_node_pools : i => s }

  provider                = azurerm.spoke
  name                    = each.value.name
  vm_size                 = each.value.vm_size
  vnet_subnet_id          = data.azurerm_subnet.aks.id
  kubernetes_cluster_id   = azurerm_kubernetes_cluster.this.id
  os_disk_size_gb         = each.value.disk_size
  auto_scaling_enabled    = true
  min_count               = each.value.min_count
  max_count               = each.value.max_count
  node_count              = each.value.min_count
  os_type                 = each.value.os_type
  priority                = var.aks_use_spot ? "Spot" : "Regular"
  spot_max_price          = var.aks_use_spot ? -1 : null
  eviction_policy         = var.aks_use_spot ? "Delete" : null
  host_encryption_enabled = true

  lifecycle {
    ignore_changes = [node_count, node_taints, node_labels, upgrade_settings, windows_profile]
  }
}

# Roles

resource "azurerm_role_assignment" "aks_vnet_reader" {
  provider             = azurerm.spoke
  scope                = data.azurerm_virtual_network.this.id
  role_definition_name = "Network Contributor"
  principal_id         = length(var.kms_key_vault_id) > 0 && local.kms_network_access == "Private" ? azurerm_user_assigned_identity.aks[0].principal_id : azurerm_kubernetes_cluster.this.identity[0].principal_id
}

# TODO - We need to grant permissions to the pipeline SP (not the terraform SP), so that it can do helm deploys
# resource "azurerm_role_assignment" "pipeline_aks_cluster_admin" {
#   scope                = azurerm_kubernetes_cluster.this.id
#   role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
#   principal_id         = data.azurerm_client_config.current.object_id # TODO - Need to decide on how we name the pipeline_principal_id variable to differentiate it from var.principal_id
# }
