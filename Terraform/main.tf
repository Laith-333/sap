# -------------------------
# VARIABLES
# -------------------------

variable "subscription_id" {
  default = "e8fd00c7-068f-4e91-9d44-5e9cdaf82185"
}

variable "resource_group_name" {
  default = "SAP_Enveriment_RG"
}

variable "location" {
  default = "italynorth"
}

variable "vnet_name" {
  default = "SAP_Enveriment_Network"
}

variable "subnet_name" {
  default = "Subnet_Secrets"
}

variable "vnet_address_space" {
  default = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  default = ["10.0.0.0/27"]
}

variable "tags" {
  default = {
    pipelines = "secrets"
  }
}

# -------------------------
# PROVIDER
# -------------------------

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# -------------------------
# DATA
# -------------------------

data "azurerm_client_config" "current" {}

# -------------------------
# RESOURCE GROUP
# -------------------------

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# -------------------------
# VIRTUAL NETWORK
# -------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = var.vnet_address_space
  tags          = var.tags
}

# -------------------------
# SUBNET
# -------------------------

resource "azurerm_subnet" "subnet_secrets" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = var.subnet_prefix
}

# -------------------------
# KEY VAULT
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
# ACCESS POLICY
# -------------------------

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]

  key_permissions = [
    "Get",
    "List"
  ]
}

# -------------------------
# WAIT FOR PERMISSIONS
# -------------------------

resource "time_sleep" "wait_for_permissions" {
  depends_on = [
    azurerm_key_vault_access_policy.current_user
  ]

  create_duration = "60s"
}

# -------------------------
# SECRETS
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
