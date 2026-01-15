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
    value = var.web_app_routing_enabled ? azurerm_kubernetes_cluster.this.web_app_routing[0].web_app_routing_identity[0].client_id : null
}

output "webapprouting_identity_principal_id" {
    value = var.web_app_routing_enabled ? azurerm_kubernetes_cluster.this.web_app_routing[0].web_app_routing_identity[0].object_id : null
}

output "kubernetes_cluster_id" {
    value = azurerm_kubernetes_cluster.this.id
}

output "oidc_issuer_url" {
    value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "node_resource_group_id" {
    value = azurerm_kubernetes_cluster.this.node_resource_group_id
}

output "outbound_ip_addresses" {
    description = "The outbound public IP addresses used by the AKS cluster"
    value = [
        for ip in azurerm_kubernetes_cluster.this.network_profile[0].load_balancer_profile[0].effective_outbound_ips : 
        ip
    ]
}

output "outbound_ip_address" {
    description = "The primary outbound public IP address used by the AKS cluster"
    value = length(azurerm_kubernetes_cluster.this.network_profile[0].load_balancer_profile[0].effective_outbound_ips) > 0 ? azurerm_kubernetes_cluster.this.network_profile[0].load_balancer_profile[0].effective_outbound_ips[0] : null
}