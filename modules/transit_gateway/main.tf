# Provision the Central Transit Gateway

resource "aws_ec2_transit_gateway" "tgw" {
  description   = "Central Cloud Router for Multi-VPC Architecture"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = {Name  = "central-tgw"} 
}

# Dynamic iterator mapping VPC attachments directly to the central router loop

resource "aws_ec2_transit_gateway_vpc_attachment" "attachments" {
  for_each           = var.vpc_attachments
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = each.value


# Discovers and binds to an active subnet group automatically per VPC

subnet_ids = var.subnet_ids[each.key]

tags    =   {Name   ="tgw-attachment-${each.key}"}
}

# Helper data source to locate available subnets dynamically per runtime binding

data "aws_subnets" "lookup" {
  for_each = var.vpc_attachments
  filter{
    name    ="vpc-id"
    values = [each.value]
  }
}