resource "azurerm_resource_group" "bootcamp_rg" {
  name     = "${var.naming-prefix}-rg"
  location = "Sweden Central"
  tags     = var.tags
}