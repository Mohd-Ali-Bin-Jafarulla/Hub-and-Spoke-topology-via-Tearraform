variable "hub_vpc_id" {
  type = string
  description = "The central hub VPC target identifier"
}

variable "vpc_attachments" {
  type = map(string)
  description = "Map configuration tracking names and associated network IDs"
}

variable "subnet_ids" {
  type = map(list(string))
  description = "Map of subnet IDs per VPC for attachments"
}