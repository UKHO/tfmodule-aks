output "identity_principal_id" {
    value = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "secret_identity_principal_id" {
    value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
}

output "secret_identity_client_id" {
    value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].client_id
}

output "kubelet_identity_principal_id" {
    value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "webapprouting_identity_client_id" {
    value = azurerm_kubernetes_cluster.this.web_app_routing[0].web_app_routing_identity[0].client_id
}

output "webapprouting_identity_principal_id" {
    value = azurerm_kubernetes_cluster.this.web_app_routing[0].web_app_routing_identity[0].object_id
}

output "kubernetes_cluster_id" {
    value = azurerm_kubernetes_cluster.this.id
}

output "oidc_issuer_url" {
    value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}