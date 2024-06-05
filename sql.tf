resource "azurerm_postgresql_flexible_server" "psql" {
  name                          = "${var.naming-prefix}-psql"
  resource_group_name           = azurerm_resource_group.bootcamp_rg.name
  location                      = azurerm_resource_group.bootcamp_rg.location
  version                       = "14"
  delegated_subnet_id           = azurerm_subnet.psql_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.psql_dns.id
  public_network_access_enabled = false
  zone                          = "2"

  storage_mb   = 32768
  storage_tier = "P30"

  sku_name = "GP_Standard_D4s_v3"
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }
 tags = var.tags
}
