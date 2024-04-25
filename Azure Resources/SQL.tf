resource "azurerm_sql_server" "icc_vehicle_sql_server" {
  name                         = "iccvechilesqlserver"
  resource_group_name          = azurerm_resource_group.icc_project.name
  location                     = azurerm_resource_group.icc_project.location
  version                      = "12.0"
  administrator_login          = "iccadmin"
  administrator_login_password = "Iccpwd@5566"

  #   tags = {
  #     environment = "production"
  #   }
}

resource "azurerm_sql_database" "icc_vehicle_data_sql" {
  name                = "icc-vehicle-db"
  resource_group_name = azurerm_resource_group.icc_project.name
  location            = azurerm_resource_group.icc_project.location
  server_name         = azurerm_sql_server.icc_vehicle_sql_server.name
  max_size_gb         = 1

  #   tags = {
  #     environment = "production"
  #   }

  # prevent the possibility of accidental data loss
  #   lifecycle {
  #     prevent_destroy = true
  #   }
}


resource "azurerm_sql_firewall_rule" "icc_sql_server_firewall_rule" {
  name                = "AllowAnyIpAddress"
  resource_group_name = azurerm_resource_group.icc_project.name
  server_name         = azurerm_sql_server.icc_vehicle_sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
