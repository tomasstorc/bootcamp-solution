

resource "azurerm_private_endpoint" "pe_kv" {
  name                = "ts-test-bootcamp-kv-pen"
  location            = azurerm_resource_group.bootcamp_rg.location
  resource_group_name = azurerm_resource_group.bootcamp_rg.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_dns.id]
  }

  private_service_connection {
    name                           = "ts-test-bootcamp-kv-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }
  tags = var.tags
}
