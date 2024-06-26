resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.naming-prefix}-law"
  location            = azurerm_resource_group.bootcamp_rg.location
  resource_group_name = azurerm_resource_group.bootcamp_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}