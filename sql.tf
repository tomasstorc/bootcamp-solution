resource "azurerm_mssql_server" "server" {
  name                = "ts-test-bootcamp-sql"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "12.0"
  azuread_administrator {
    login_username              = "sqladmin"
    object_id                   = data.azuread_user.myself.object_id
    azuread_authentication_only = true
  }
}

# Create SQL database
resource "azurerm_mssql_database" "db" {
  name                        = "ts-test-bootcamp-db"
  server_id                   = azurerm_mssql_server.server.id
  max_size_gb                 = 4
  auto_pause_delay_in_minutes = 15
}

resource "azurerm_sql_active_directory_administrator" "example" {
  server_name         = azurerm_sql_server
  resource_group_name = azurerm_resource_group.example.name
  login               = "sqladmin"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}