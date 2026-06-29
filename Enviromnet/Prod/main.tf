# 🏢 1. Deploy Central Hub Infrastructure
module "hub_network" {
  source             = "../../modules/vpc_hub"
  hub_vpc_cidr       = var.hub_cidr
  public_subnet_cidr = var.hub_public_subnet_cidr
}

# 🛠️ 2. Deploy Workload Spoke VPC 1 (Created BEFORE TGW attachments)
module "spoke_network_1" {
  source              = "../../modules/vpc_spoke"
  spoke_name          = "${var.project_name}-spoke1"
  spoke_vpc_cidr      = var.spoke1_cidr
  private_subnet_cidr = var.spoke1_private_subnet_cidr
  tgw_id              = module.transit_gateway.tgw_id
}

# 📂 3. Deploy Workload Spoke VPC 2 (Created BEFORE TGW attachments)
module "spoke_network_2" {
  source              = "../../modules/vpc_spoke"
  spoke_name          = "${var.project_name}-spoke2"
  spoke_vpc_cidr      = var.spoke2_cidr
  private_subnet_cidr = var.spoke2_private_subnet_cidr
  tgw_id              = module.transit_gateway.tgw_id
}

# 🎛️ 4. Deploy Transit Gateway Router Mechanism
module "transit_gateway" {
  source     = "../../modules/transit_gateway"
  hub_vpc_id = module.hub_network.vpc_id
  
  vpc_attachments = {
    hub     = module.hub_network.vpc_id
    spoke_1 = module.spoke_network_1.vpc_id
    spoke_2 = module.spoke_network_2.vpc_id
  }

  
  subnet_ids = {
    hub     = [module.hub_network.public_subnet_id]
    spoke_1 = [module.spoke_network_1.private_subnet_id]
    spoke_2 = [module.spoke_network_2.private_subnet_id]
  }
}