# Azure Key Vault for encryption key management
resource "azurerm_key_vault" "main" {
  name                        = "kv-${var.project}-${var.environment}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = "standard"
}

# Key Vault Access Policy for the application
resource "azurerm_key_vault_access_policy" "app" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update",
    "Import", "Backup", "Restore", "Recover"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Backup",
    "Restore", "Recover"
  ]
}

# Disk encryption set
resource "azurerm_disk_encryption_set" "main" {
  name                = "des-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  key_vault_key_id    = azurerm_key_vault_key.encryption.id

  identity {
    type = "SystemAssigned"
  }
}

# Encryption key
resource "azurerm_key_vault_key" "encryption" {
  name         = "key-disk-encryption"
  key_vault_id = azurerm_key_vault.main.id
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