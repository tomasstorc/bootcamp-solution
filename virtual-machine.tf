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
  tags = var.tags
}


resource "azurerm_virtual_machine_extension" "ama" {
  name                       = "AzureMonitorWindowsAgent"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.14"
  virtual_machine_id         = azurerm_windows_virtual_machine.win_vm.id
}

resource "azurerm_virtual_machine_extension" "da" {
  name                       = "DependencyAgentWindows"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  settings = jsonencode(
    {
      "enableAMA" = "true"
    }
  )
  type                 = "DependencyAgentWindows"
  type_handler_version = "9.10"
  virtual_machine_id   = azurerm_windows_virtual_machine.win_vm.id
}