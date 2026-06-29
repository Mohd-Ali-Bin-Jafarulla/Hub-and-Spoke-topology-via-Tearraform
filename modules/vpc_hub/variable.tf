variable "hub_vpc_cidr" {
  type = string
  description = "CIDR block allocated for Hub VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block allocated for Hub Public Subnet"
}
