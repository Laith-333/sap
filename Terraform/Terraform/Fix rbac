variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "e8fd00c7-068f-4e91-9d44-5e9cdaf82185"
}

variable "resource_provider_registrations" {
  description = "Provider registration mode"
  type        = string
  default     = "none"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "SAP_Enveriment_RG"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Italy North"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "SAP_Enveriment_Network"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "Subnet_Secrets"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "Address prefix for the subnet"
  type        = list(string)
  default     = ["10.0.0.0/27"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    piplines = "secrets"
  }
}
