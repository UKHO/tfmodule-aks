resource "azurerm_kubernetes_cluster_extension" "flux" {
  provider       = azurerm.spoke
  name           = "flux"
  cluster_id     = azurerm_kubernetes_cluster.this.id
  extension_type = "microsoft.flux"
  version        = "1.18.2"

  configuration_settings = {
    "image-reflector-controller.enabled"  = tostring(var.flux_image_reflector_controller_enabled)
    "image-automation-controller.enabled" = tostring(var.flux_image_automation_controller_enabled)
  }

  count = var.flux_enabled ? 1 : 0
}

resource "azurerm_kubernetes_flux_configuration" "flux" {
  provider   = azurerm.spoke
  name       = "flux-system"
  cluster_id = azurerm_kubernetes_cluster.this.id
  namespace  = "flux-system"

  git_repository {
    url                    = var.flux_git_repository_url
    reference_type         = var.flux_git_reference_type
    reference_value        = var.flux_git_reference_value
    ssh_private_key_base64 = var.flux_ssh_private_key_base64
  }

  kustomizations {
    name                       = "flux"
    path                       = var.flux_git_repository_path
    sync_interval_in_seconds   = 120
    retry_interval_in_seconds  = 120
    garbage_collection_enabled = true

    post_build {
      substitute = {
        secret_identity_client_id = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].client_id
      }
    }
  }

  dynamic "kustomizations" {
    for_each = var.flux_image_automation_controller_enabled && length(var.flux_image_automation_kustomization_path) > 0 ? [1] : []
    content {
      name                       = "image-automation"
      path                       = var.flux_image_automation_kustomization_path
      garbage_collection_enabled = true
      sync_interval_in_seconds   = 300
    }
  }

  scope = "cluster"

  depends_on = [
    azurerm_kubernetes_cluster_extension.flux.0
  ]

  count = var.flux_enabled && var.apply_flux_configuration ? 1 : 0
}
