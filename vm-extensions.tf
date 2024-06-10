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

resource "azurerm_virtual_machine_extension" "CSE" {
  count                = var.script_uri != "" ? 1 : 0
  name                 = "CustomScriptExtensions"
  virtual_machine_id   = azurerm_windows_virtual_machine.win_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
 {
  "fileUris": ["${var.script_uri}"],
  "commandToExecute": "powershell.exe installPython.ps1"
 }
SETTINGS


  tags = var.tags
}
