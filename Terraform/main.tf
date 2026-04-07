terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# -------------------------
# Reference existing Key Vault
# -------------------------
data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

# -------------------------
# Upload file as secret
# -------------------------
resource "azurerm_key_vault_secret" "config" {
  name         = var.secret_name
  value        = file(var.file_path)
  key_vault_id = data.azurerm_key_vault.kv.id
}
