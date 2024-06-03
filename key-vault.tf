resource "azurerm_key_vault" "kv" {
  name                          = "ts-test-bootcamp-kv3"
  location                      = azurerm_resource_group.bootcamp_rg.location
  resource_group_name           = azurerm_resource_group.bootcamp_rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  public_network_access_enabled = false
}

