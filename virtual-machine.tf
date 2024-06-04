resource "azurerm_windows_virtual_machine" "win_vm" {
  name                = "ts-test-vm"
  resource_group_name = azurerm_resource_group.bootcamp_rg.name
  location            = azurerm_resource_group.bootcamp_rg.location
  size                = "Standard_F2"
  admin_username      = "tomasstorc"
  admin_password      = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.private_vm_nic.id
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

