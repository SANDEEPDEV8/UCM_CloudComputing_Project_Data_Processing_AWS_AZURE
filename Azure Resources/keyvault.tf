resource "azurerm_key_vault" "icc_project_kv" {
  name                        = "icc-project-kv"
  location                    = azurerm_resource_group.icc_project.location
  resource_group_name         = azurerm_resource_group.icc_project.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  #   soft_delete_retention_days  = 7
  purge_protection_enabled = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Rotate", "GetRotationPolicy", "SetRotationPolicy", "Purge"
    ]

    secret_permissions = [
      "Get", "Set", "List", "Delete", "Recover", "Backup", "Restore", "Purge"
    ]

    storage_permissions = [
      "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
    ]
  }
}


resource "azurerm_key_vault_secret" "s3_access_key_id" {
  name         = "s3-access-key-id"
  value        = "AKIAU6GDZ3VUDMH3IGI7"
  key_vault_id = azurerm_key_vault.icc_project_kv.id
}

resource "azurerm_key_vault_secret" "s3_secret_key" {
  name         = "s3-secret-key"
  value        = "Oh98ertVs+BQFtjuB8QtQcbhK1RPfatWooHkTLd2"
  key_vault_id = azurerm_key_vault.icc_project_kv.id
}



resource "azurerm_key_vault_access_policy" "icc_adf_kv_access" {
  key_vault_id = azurerm_key_vault.icc_project_kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_data_factory.icc_adf.identity[0].principal_id


  key_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get", "List"
  ]

  storage_permissions = [
    "Get", "List"
  ]
}
