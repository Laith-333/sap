provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

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
  tags          = var.tags
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
# Key Vault
# -------------------------
resource "azurerm_key_vault" "kv" {
  name                = "peiplnessecrets123"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  tags = var.tags
}

# -------------------------
# Wait for KV
# -------------------------
resource "time_sleep" "wait_for_permissions" {
  depends_on = [azurerm_key_vault.kv]
  create_duration = "60s"
}

# -------------------------
# Secrets (FIXED SYNTAX)
# -------------------------

resource "azurerm_key_vault_secret" "pipelines" {
  count = var.target_secret == "pipelines" ? 1 : 0

  name = "pipelines-config"

  value = var.action == "create_new" && var.secret_value != "" ? var.secret_value : file("${path.module}/pipelines.env")

  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [time_sleep.wait_for_permissions]
}

resource "azurerm_key_vault_secret" "microsoft" {
  count = var.target_secret == "microsoft" ? 1 : 0

  name = "microsoft-config"

  value = var.action == "create_new" && var.secret_value != "" ? var.secret_value : file("${path.module}/microsoft.env")

  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [time_sleep.wait_for_permissions]
}

resource "azurerm_key_vault_secret" "jumbo" {
  count = var.target_secret == "jumbo" ? 1 : 0

  name = "jumbo-config"

  value = var.action == "create_new" && var.secret_value != "" ? var.secret_value : file("${path.module}/jumbo.env")

  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [time_sleep.wait_for_permissions]
}
