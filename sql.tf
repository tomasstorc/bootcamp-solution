resource "azurerm_mssql_server" "server" {
  name                         = "ts-test-bootcamp-sql"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  azuread_administrator {
    login_username = data.azuread_user.current_user.display_name
    object_id = data.azurerm_client_config.current.object_id
    azuread_authentication_only = true
  }
}

# Create SQL database
resource "azurerm_mssql_database" "db" {
  name      = "ts-test-bootcamp-db"
  server_id = azurerm_mssql_server.server.id
  max_size_gb = 4
  auto_pause_delay_in_minutes = 15
}