# 1.Global Custom Metadata Tags

project_name = "Hub-and-Spoke-Network"
environment = "Prod"
managed_by = "Terraform"

# 2.Target Cloud Deployment Zone

aws_region = "ap-southeast-1"

# 3.Central Hub Network Topology (10.0.0.0/16)

hub_cidr = "10.0.0.0/16"
hub_public_subnet_cidr = "10.0.1.0/24"

# 4.Isolated Workload Spoke 1 Addressing (10.1.0.0/16)

spoke1_cidr = "10.1.0.0/16"
spoke1_private_subnet_cidr = "10.1.1.0/24"

# 5. Isolated Workload Spoke 2 Addressing (10.2.0.0/16)

spoke2_cidr = "10.2.0.0/16"
spoke2_private_subnet_cidr = "10.2.1.0/24"