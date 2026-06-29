output "vpc_id" {
  value = aws_vpc.spoke.id
  description = "ID of the generated Spoke VPC"
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}