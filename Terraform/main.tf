terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# -------------------------
# READ existing Key Vault (DATA = read only)
# -------------------------
data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

# -------------------------
# CREATE secret inside Key Vault
# -------------------------
resource "azurerm_key_vault_secret" "config" {
  name         = var.secret_name
  value        = file(var.file_path)
  key_vault_id = data.azurerm_key_vault.kv.id
}
