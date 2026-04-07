variable "subscription_id" {
  default = "e8fd00c7-068f-4e91-9d44-5e9cdaf82185"
}

variable "resource_group_name" {
  default = "SAP_Environment_RG"
}

variable "location" {
  default = "italynorth"
}

variable "vnet_name" {
  default = "SAP_Environment_Network"
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
