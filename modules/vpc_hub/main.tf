# Create the Central Hub VPC

resource "aws_vpc" "hub" {
  cidr_block = var.hub_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name    = "central-hub-vpc"
  }
}

# Internet Gateway for public routing

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hub.id
  tags = {Name  = "hub-igw"}
}

# Public Subnet hosting the NAT Gateway

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.hub.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags = {Name  =   "hub-public-subnet"}
}

# Static IP for NAT Gateway stability

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {Name  =   "hub-nat-eip"}
}

# NAT Gateway enabling secure outbound communication for Spokes

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public.id
  tags = {Name  =   "hub-nat-gateway"}

  # Ensures correct ordering; won't deploy until the IGW is live
  depends_on = [ aws_internet_gateway.igw ]
}

# Public Route Table mapping outbound traffic straight to the Internet

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.hub.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {Name  =   "hub-public-rt"}
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}