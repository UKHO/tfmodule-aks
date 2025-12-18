data "azurerm_key_vault" "kms" {
  count = length(var.kms_key_vault_id) > 0 ? 1 : 0

  name                = split("/", var.kms_key_vault_id)[8]
  resource_group_name = split("/", var.kms_key_vault_id)[4]
}

resource "azurerm_key_vault_key" "kms" {
  count = length(var.kms_key_vault_id) > 0 ? 1 : 0

  name         = "${var.aks_name}-kms-key"
  key_vault_id = var.kms_key_vault_id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

locals {
  kms_key_id         = length(var.kms_key_vault_id) > 0 ? azurerm_key_vault_key.kms[0].id : ""
  kms_network_access = length(var.kms_key_vault_id) > 0 ? (data.azurerm_key_vault.kms[0].public_network_access_enabled ? "Public" : "Private") : "Public"
}
