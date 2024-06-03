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
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_subnet" "psql_subnet" {
  name                 = "ts-test-bootcamp-sub2"
  resource_group_name  = azurerm_resource_group.bootcamp_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.64/26"]
  delegation {
    name = "sd"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }

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
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}




