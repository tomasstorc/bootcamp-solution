# info about current user
data "azurerm_client_config" "current" { }
data "azuread_user" "current_user" {
  object_id = data.azurerm_client_config.current.object_id
}

data "azuread_user" "myself" {
  object_id = var.user_id
}

# generate random pw
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_upper = 1
  min_numeric = 5
}