# access from vm to key vault
resource "azurerm_role_assignment" "kv_rbac" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_windows_virtual_machine.win_vm.identity[0].principal_id
}

