variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where Key Vault exists"
  type        = string
  default     = "SAP_Environment_RG"
}

variable "key_vault_name" {
  description = "Existing Key Vault name"
  type        = string
  default     = "peiplnessecrets8ie6i"
}

variable "secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "file_path" {
  description = "Path to file to upload"
  type        = string
}
