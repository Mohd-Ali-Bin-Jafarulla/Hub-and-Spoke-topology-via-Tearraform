output "tgw_id" {
  value       = aws_ec2_transit_gateway.tgw.id
  description = "Exposes generated Transit Gateway unique ID"
}