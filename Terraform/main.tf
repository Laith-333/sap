provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

# Detect current identity (GitHub / Terraform)
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
# ✅ ACCESS FOR TERRAFORM (service principal)
# -------------------------
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

# -------------------------
# ✅ ACCESS FOR YOU (VERY IMPORTANT FIX)
# -------------------------
resource "azurerm_key_vault_access_policy" "your_user" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id

  # 🔥 PUT YOUR USER OBJECT ID HERE
  object_id = var.user_object_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# -------------------------
# ⏳ Wait for permissions
# -------------------------
resource "time_sleep" "wait_for_permissions" {
  depends_on = [
    azurerm_key_vault_access_policy.terraform,
    azurerm_key_vault_access_policy.your_user
  ]

  create_duration = "60s"
}

# -------------------------
# Secrets
# -------------------------
resource "azurerm_key_vault_secret" "pipelines" {
  name         = "pipelines-config"
  value        = file("${path.module}/pipelines.env")
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_permissions]
}

resource "azurerm_key_vault_secret" "microsoft" {
  name         = "microsoft-config"
  value        = file("${path.module}/microsoft.env")
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_permissions]
}

resource "azurerm_key_vault_secret" "jumbo" {
  name         = "jumbo-config"
  value        = file("${path.module}/jumbo.env")
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_permissions]
}
