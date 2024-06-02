# info about current user
data "azurerm_client_config" "current" {}


# generate random pw
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_upper        = 1
  min_numeric      = 5
}