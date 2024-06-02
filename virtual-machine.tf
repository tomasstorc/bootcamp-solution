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