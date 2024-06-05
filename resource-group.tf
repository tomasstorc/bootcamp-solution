resource "azurerm_resource_group" "bootcamp_rg" {
  name     = "ts-test-bootcamp-rg"
  location = "Sweden Central"
  tags = var.tags
}