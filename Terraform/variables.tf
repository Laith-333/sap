variable "subscription_id" {
  description = "Azure Subscription ID"
  default     = "e8fd00c7-068f-4e91-9d44-5e9cdaf82185"
}

variable "resource_group_name" {
  description = "Resource group where Key Vault exists"
  default     = "SAP_Environment_RG"
}

variable "key_vault_name" {
  description = "Existing Key Vault name"
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
