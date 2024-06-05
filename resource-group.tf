resource "azurerm_resource_group" "bootcamp_rg" {
  name     = "${var.naming-prefix}-rg"
  location = var.location
  tags     = var.tags
}