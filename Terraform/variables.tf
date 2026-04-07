variable "subscription_id" {
  default = "e8fd00c7-068f-4e91-9d44-5e9cdaf82185"
}

variable "resource_group_name" {
  default = "SAP_Environment_RG"
}

variable "key_vault_name" {
  default = "peiplnessecrets8ie6i"
}

variable "secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "file_path" {
  description = "Path to file"
  type        = string
}
