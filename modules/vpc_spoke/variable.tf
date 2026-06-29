variable "spoke_name" {
  type = string
  description = "Unique naming identifier string for the spoke network"
}

variable "spoke_vpc_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "tgw_id" {
  type = string
  description = "The central Transit Gateway identifier routed from parent module"
}