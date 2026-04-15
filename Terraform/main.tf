provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}


data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = data.azurerm_resource_group.rg.name
}


resource "azurerm_key_vault_secret" "config" {
  name         = var.secret_name
  value        = file(var.file_path)
  key_vault_id = data.azurerm_key_vault.kv.id
}
