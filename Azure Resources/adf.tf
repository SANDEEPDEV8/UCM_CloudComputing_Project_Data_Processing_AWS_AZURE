resource "azurerm_data_factory" "icc_adf" {
  name                = "icc-afd"
  location            = azurerm_resource_group.icc_project.location
  resource_group_name = azurerm_resource_group.icc_project.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_linked_service_key_vault" "icc_adf_ls_to_kv" {
  name            = "icc-adf-ls-to-kv"
  data_factory_id = azurerm_data_factory.icc_adf.id
  key_vault_id    = azurerm_key_vault.icc_project_kv.id
}

resource "azurerm_data_factory_linked_custom_service" "icc_adf_la_to_s3" {
  name            = "icc-adf-la-to-s3"
  data_factory_id = azurerm_data_factory.icc_adf.id
  type            = "AmazonS3"
  description     = "Connects ADF to AWS S3"

  type_properties_json = jsonencode({
    accessKeyId : azurerm_key_vault_secret.s3_access_key_id.value,
    secretAccessKey : {
      type : "SecureString",
      value : azurerm_key_vault_secret.s3_secret_key.value
    }
  })
  parameters = {
    "foo" : "bar"
    "Env" : "Test"
  }

}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "adf_to_adls_ls" {
  name            = "adf-to-adls-ls"
  data_factory_id = azurerm_data_factory.icc_adf.id

  storage_account_key = "s+AXrHWOLE/015yaWgfNpJr5ULct1iaRXnKzPpBU8mIGEQzPARokO1CZUEJNAsTcf7G+gS+Yxzyy+AStRq849w==" //azurerm_storage_account.icc_st_account.name
  url                 = "https://${azurerm_storage_account.icc_st_account.name}.dfs.core.windows.net/"
}
resource "azurerm_data_factory_linked_service_azure_sql_database" "adf_to_sql_ls" {
  name              = "adf-to-sql-ls"
  data_factory_id   = azurerm_data_factory.icc_adf.id
  connection_string = "data source=tcp:${azurerm_sql_server.icc_vehicle_sql_server.name}.database.windows.net,1433;initial catalog=${azurerm_sql_database.icc_vehicle_data_sql.name};user id=${azurerm_sql_server.icc_vehicle_sql_server.administrator_login};Password=${azurerm_sql_server.icc_vehicle_sql_server.administrator_login_password};integrated security=False;encrypt=True;connection timeout=30"
}
