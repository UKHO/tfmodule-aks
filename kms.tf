data "azurerm_key_vault" "kms" {
  count = length(var.kms_key_vault_id) > 0 ? 1 : 0

  name                = split("/", var.kms_key_vault_id)[8]
  resource_group_name = split("/", var.kms_key_vault_id)[4]
}

resource "azurerm_key_vault_key" "kms" {
  count = length(var.kms_key_vault_id) > 0 ? 1 : 0

  name            = "${var.aks_name}-kms-key"
  key_vault_id    = var.kms_key_vault_id
  key_type        = "RSA"
  key_size        = 2048
  expiration_date = timeadd(timestamp(), "87600h")

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

locals {
  kms_key_id         = length(var.kms_key_vault_id) > 0 ? azurerm_key_vault_key.kms[0].id : ""
  kms_network_access = length(var.kms_key_vault_id) > 0 ? (data.azurerm_key_vault.kms[0].public_network_access_enabled ? "Public" : "Private") : "Public"
}

# Key Vault access for User-Assigned Managed Identity when VNet integration is enabled
resource "azurerm_role_assignment" "kms_key_vault_crypto" {
  count = length(var.kms_key_vault_id) > 0 && local.kms_network_access == "Private" ? 1 : 0

  scope                = var.kms_key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Key Vault Administrator access for Private Endpoint connection approval
# resource "azurerm_role_assignment" "kms_key_vault_admin" {
#   count = length(var.kms_key_vault_id) > 0 && local.kms_network_access == "Private" ? 1 : 0

#   scope                = var.kms_key_vault_id
#   role_definition_name = "Key Vault Administrator"
#   principal_id         = azurerm_user_assigned_identity.aks.principal_id
# }

# Custom role for Private Endpoint connection approval
resource "azurerm_role_definition" "private_endpoint_approval" {
  count = length(var.kms_key_vault_id) > 0 && local.kms_network_access == "Private" ? 1 : 0

  name        = "${var.aks_name}-private-endpoint-approval"
  scope       = var.kms_key_vault_id
  description = "Custom role for approving private endpoint connections to Key Vault"

  permissions {
    actions = [
      "Microsoft.KeyVault/vaults/PrivateEndpointConnectionsApproval/action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    var.kms_key_vault_id
  ]
}

# Alternative: Use custom role for private endpoint approval (comment out the admin role assignment above if using this)
resource "azurerm_role_assignment" "kms_private_endpoint_approval" {
  count = length(var.kms_key_vault_id) > 0 && local.kms_network_access == "Private" ? 1 : 0

  scope                = var.kms_key_vault_id
  role_definition_id   = azurerm_role_definition.private_endpoint_approval[0].role_definition_resource_id
  principal_id         = azurerm_user_assigned_identity.aks.principal_id

  depends_on = [azurerm_role_definition.private_endpoint_approval]
}

# Network Contributor access for User-Assigned Managed Identity over the AKS subnet
resource "azurerm_role_assignment" "aks_subnet_network_contributor" {
  count = length(var.kms_key_vault_id) > 0 && local.kms_network_access == "Private" ? 1 : 0

  scope                = data.azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id

  depends_on = [azurerm_user_assigned_identity.aks]
}
