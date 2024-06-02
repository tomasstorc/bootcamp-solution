# access from vm to key vault
resource "azurerm_role_assignment" "example" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_windows_virtual_machine.win_vm.identity.principal_id
}

#give yourself ad access to vm
resource "azurerm_role_assignment" "example" {
  scope                = azurerm_windows_virtual_machine.win_vm.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = data.azuread_user.myself.object_id
}

