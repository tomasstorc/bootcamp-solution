data "azurerm_client_config" "current" { }
data "azuread_user" "current_user" {
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_resource_group" "bootcamp_rg" {
  name     = "ts-test-bootcamp-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ts-test-bootcamp-vnet"
  address_space       = ["10.0.0.0/25"]
  location            = azurerm_resource_group.bootcamp_rg.location
  resource_group_name = azurerm_resource_group.bootcamp_rg.name
}

resource "azurerm_subnet" "pe_subnet" {
  name                 = "ts-test-bootcamp-sub1"
  resource_group_name  = azurerm_resource_group.bootcamp_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/26"]
}

resource "azurerm_subnet" "sql_subnet" {
  name                 = "ts-test-bootcamp-sub2"
  resource_group_name  = azurerm_resource_group.bootcamp_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.64.0/26"]

}

resource "azurerm_public_ip" "public_ip" {
  name                = "ts-test-bootcamp-pip"
  resource_group_name = azurerm_resource_group.bootcamp_rg.name
  location            = azurerm_resource_group.bootcamp_rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "private_vm_nic" {
  name                = "ts-test-bootcamp-nic"
  location            = azurerm_resource_group.bootcamp_rg.location
  resource_group_name = azurerm_resource_group.bootcamp_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.pe_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_upper = 1
  min_numeric = 5
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "ts-test-bootcamp-vm"
  resource_group_name = azurerm_resource_group.bootcamp_rg.name
  location            = azurerm_resource_group.bootcamp_rg.location
  size                = "Standard_F2"
  admin_username      = "tomasstorc"
  admin_password      = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.private_vm_nic.id,
  ]
  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  name                       = "vmext-AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.example.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}


# Create SQL server
resource "azurerm_mssql_server" "server" {
  name                         = "ts-test-bootcamp-sql"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  azuread_administrator {
    login_username = data.azuread_user.current_user.display_name
    object_id = data.azurerm_client_config.current.object_id
    azuread_authentication_only = true
  }
}

# Create SQL database
resource "azurerm_mssql_database" "db" {
  name      = "ts-test-bootcamp-db"
  server_id = azurerm_mssql_server.server.id
  max_size_gb = 4
  auto_pause_delay_in_minutes = 15
}

# Create private endpoint for SQL server
resource "azurerm_private_endpoint" "my_terraform_endpoint" {
  name                = "private-endpoint-sql"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sql_subnet.id

  private_service_connection {
    name                           = "private-serviceconnection"
    private_connection_resource_id = azurerm_mssql_server.server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.bootcamp_dns.id]
  }
}

# Create private DNS zone
resource "azurerm_private_dns_zone" "bootcamp_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.bootcamp_rg.name
}

# Create virtual network link
resource "azurerm_private_dns_zone_virtual_network_link" "my_terraform_vnet_link" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.bootcamp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.bootcamp_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_key_vault" "kv" {
  name                        = "ts-test-bootcamp-kv"
  location                    = azurerm_resource_group.bootcamp_rg.location
  resource_group_name         = azurerm_resource_group.bootcamp_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = true
  public_network_access_enabled = false
}



resource "azurerm_private_endpoint" "pe_kv" {
  name                = "ts-test-bootcamp-kv-pen"
  location            = data.azurerm_resource_group.bootcamp_rg.location
  resource_group_name = data.azurerm_resource_group.bootcamp_rg.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }

  private_service_connection {
    name                           = "ts-test-bootcamp-kv-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names = ["Vault"]
  }
}
resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.bootcamp_rg.name
  
}