provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_secrets = false
    }
  }
  subscription_id                 = var.subscription_id
  resource_provider_registrations = var.resource_provider_registrations
}

# Required for time_sleep resource
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}

# Detect identity (works for local + GitHub)
data "azurerm_client_config" "current" {}

# -------------------------
# Resource Group
# -------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# -------------------------
# Virtual Network
# -------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# -------------------------
# Subnet
# -------------------------
resource "azurerm_subnet" "subnet_secrets" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefix
}

# -------------------------
# Key Vault (ACCESS POLICY MODE - no RBAC needed)
# -------------------------
resource "azurerm_key_vault" "kv" {
  name                       = "peiplnessecrets123"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = false  # Use access policies instead
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  tags                       = var.tags

  # Grant access directly in Key Vault (no separate role assignment needed)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]
  }
}

# -------------------------
# Secrets from files (no RBAC wait needed)
# -------------------------
resource "azurerm_key_vault_secret" "pipelines" {
  name         = "pipelines-config"
  value        = file("${path.module}/pipelines.env")
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "microsoft" {
  name         = "microsoft-config"
  value        = file("${path.module}/microsoft.env")
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "jumbo" {
  name         = "jumbo-config"
  value        = file("${path.module}/jumbo.env")
  key_vault_id = azurerm_key_vault.kv.id
}

# -------------------------
# Outputs
# -------------------------
output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "current_principal_id" {
  value       = data.azurerm_client_config.current.object_id
  description = "The object ID that Terraform is running as"
}
