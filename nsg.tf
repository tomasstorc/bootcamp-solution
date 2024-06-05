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

tags = var.tags
}


resource "azurerm_subnet_network_security_group_association" "rdp" {
  subnet_id                 = azurerm_subnet.pe_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_rdp.id
}