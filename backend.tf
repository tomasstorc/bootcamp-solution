terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "tstestterraformstatesa"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
    client_id            = "af6b77c1-9b4e-4463-91a6-92599feda31d"
  }
}