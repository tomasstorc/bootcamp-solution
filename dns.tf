resource "azurerm_private_dns_zone" "kv_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.bootcamp_rg.name

}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link_kv" {
  name                  = "vnet-link-kv"
  resource_group_name   = azurerm_resource_group.bootcamp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "psql_dns" {
  name                = "privatelink.postgres.database.azure.net"
  resource_group_name = azurerm_resource_group.bootcamp_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link_psql" {
  name                  = "vnet-link-psql"
  private_dns_zone_name = azurerm_private_dns_zone.psql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.bootcamp_rg.name

}