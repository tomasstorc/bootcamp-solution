resource "azurerm_private_endpoint" "sql_pe" {
  name                = "private-endpoint-sql"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sql_subnet.id

  private_service_connection {
    name                           = "ts-test-bootcamp-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns.id]
  }
}

resource "azurerm_private_endpoint" "pe_kv" {
  name                = "ts-test-bootcamp-kv-pen"
  location            = data.azurerm_resource_group.bootcamp_rg.location
  resource_group_name = data.azurerm_resource_group.bootcamp_rg.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_dns.id]
  }

  private_service_connection {
    name                           = "ts-test-bootcamp-kv-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names = ["Vault"]
  }
}
