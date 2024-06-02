resource "azurerm_network_security_group" "nsg_rdp" {
  name                = "ts-test-bootcamp-nsg1"
  location            = azurerm_resource_group.bootcamp_rg.location
  resource_group_name = azurerm_resource_group.bootcamp_rg.name

  security_rule {
    name                       = "allowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "DenyAll"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
 
}

resource "azurerm_network_security_group" "nsg_psql" {
  name                = "ts-test-bootcamp-nsg2"
  location            = azurerm_resource_group.bootcamp_rg.location
  resource_group_name = azurerm_resource_group.bootcamp_rg.name

  security_rule {
    name                       = "allowPostgre"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "DenyAll"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
 
}

resource "azurerm_subnet_network_security_group_association" "psql" {
  subnet_id                 = azurerm_subnet.psql_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_psql.id
}

resource "azurerm_subnet_network_security_group_association" "rdp" {
  subnet_id                 = azurerm_subnet.pe_subnet
  network_security_group_id = azurerm_network_security_group.nsg_rdp.id
}