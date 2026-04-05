provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  resource_provider_registrations = var.resource_provider_registrations
}

# 🔥 Detect identity (works for local + GitHub)
data "azurerm_client_config" "current" {}

# -------------------------
# Resource Group
# -------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# -------------------------
# Virtual Network
# -------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = var.vnet_address_space

  tags = var.tags
}

# -------------------------
# Subnet
# -------------------------
resource "azurerm_subnet" "subnet_secrets" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = var.subnet_prefix
}

# -------------------------
# Key Vault (RBAC ENABLED 🔥)
# -------------------------
resource "azurerm_key_vault" "kv" {
  name                = "peiplnessecrets123"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  # 🔥 FIXED (new property name)
  rbac_authorization_enabled = true

  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  tags = var.tags
}

# -------------------------
# RBAC ROLE ASSIGNMENT
# -------------------------
resource "azurerm_role_assignment" "kv_secrets" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"

  principal_id = data.azurerm_client_config.current.object_id
}

# -------------------------
# 🔥 WAIT FOR RBAC PROPAGATION
# -------------------------
resource "time_sleep" "wait_for_rbac" {
  depends_on = [azurerm_role_assignment.kv_secrets]

  create_duration = "60s"
}

# -------------------------
# Secrets from files
# -------------------------
resource "azurerm_key_vault_secret" "pipelines" {
  name         = "pipelines-config"
  value        = file("${path.module}/pipelines.env")
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_rbac]
}

resource "azurerm_key_vault_secret" "microsoft" {
  name         = "microsoft-config"
  value        = file("${path.module}/microsoft.env")
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_rbac]
}

resource "azurerm_key_vault_secret" "jumbo" {
  name         = "jumbo-config"
  value        = file("${path.module}/jumbo.env")
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_rbac]
}
