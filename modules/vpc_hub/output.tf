output "vpc_id" {
  value       = aws_vpc.hub.id
  description = "The ID of the generated Hub VPC"
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}