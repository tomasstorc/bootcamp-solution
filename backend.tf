terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "tstestterraformstatesa"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true

  }
}