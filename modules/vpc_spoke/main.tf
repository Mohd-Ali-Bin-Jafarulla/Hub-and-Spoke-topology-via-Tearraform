# Create Fully Private Spoke VPC

resource "aws_vpc" "spoke" {
  cidr_block = var.spoke_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name    = "${var.spoke_name}-vpc"
  }
}

# Private Subnet for application hosting

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.spoke.id
  cidr_block = var.private_subnet_cidr
  tags = {Name="${var.spoke_name}-private-subnet"}
}

# Private Route Table: All non-local traffic redirects to the Transit Gateway Router

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.spoke.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
  }

  tags = {Name="${var.spoke_name}-private-rt"}
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
