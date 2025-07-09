output "identity_principal_id" {
    value = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "secret_identity_principal_id" {
    value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
}