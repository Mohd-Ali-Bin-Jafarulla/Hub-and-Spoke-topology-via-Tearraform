output "deployed_hub_vpc" {
  value       = module.hub_network.vpc_id
  description = "The central hub identifier"
}

output "deployed_transit_gateway" {
  value       = module.transit_gateway.tgw_id
  description = "The core cloud router hub mesh ID"
}