# 🤝 Enterprise Hub-and-Spoke Network with Secure Inspection & Hybrid Connectivity Simulation via Terraform

### 🏢 1. Project Overview:
When transitioning from traditional network engineering to Cloud Engineering, the biggest shift is moving from static hardware/cables to Infrastructure as Code (IaC).

This project simulates a production-grade enterprise cloud network. In the real world, companies don't just throw everything into a single AWS VPC; they use multiple VPCs to isolate environments (e.g., Production, Staging, Shared Services). To prevent these VPCs from becoming disconnected islands, we use a central hub network.

---
### 📐 2. Architecture Design:
Here is the design of the network you are building. It uses a Hub-and-Spoke topology, which is the gold standard for enterprise cloud networking:

### 🔍 Key Architectural Flow:
The Hub VPC: Functions as the central clearinghouse. It contains the Internet Gateway (IGW) and NAT Gateway.

The Spoke VPCs: These house your actual applications. They are completely private and do not have their own internet gateways.

The Transit Gateway (TGW): Acts as a cloud router. If an instance in Spoke 1 needs to download a security patch from the internet, its traffic goes: Spoke 1 Private Subnet ➡️ Transit Gateway ➡️ Hub VPC NAT Gateway ➡️ Internet Gateway ➡️ Out to the Internet.

---
### 💻 3. Prerequisites & Workspace Setup

# Before writing code in VS Code, let’s ensure your local environment is prepped and clean:

AWS Account: A clean AWS account operating within the Free Tier limits.

AWS CLI Installed & Configured: Run aws sts get-caller-identity in your VS Code terminal to verify you are connected to your AWS account.

Terraform CLI: Version 1.5.0 or higher installed locally.

VS Code Extensions (Recommended): Install the official HashiCorp Terraform extension for syntax highlighting and auto-formatting.

---
### 📁 4. Terraform Structure
To make this repository look highly professional to recruiters, we avoid putting everything into a single massive file. Instead, we use a Modular Structure inside VS Code.

Open VS Code and create the following folders and empty files. This separates your reusable network components (Child Modules) from your main deployment environment (Root Module):
```text
aws-hub-spoke-tgw/
│
├── 📂 modules/                         # 👶 CHILD MODULES (Reusable blueprints)
│   ├── 📂 vpc_hub/
│   │   ├── 📄 main.tf                  # Hub VPC, IGW, NAT Gateway resources
│   │   ├── 📄 variables.tf
│   │   └── 📄 outputs.tf
│   ├── 📂 vpc_spoke/
│   │   ├── 📄 main.tf                  # Reusable Spoke VPC template
│   │   ├── 📄 variables.tf
│   │   └── 📄 outputs.tf
│   └── 📂 transit_gateway/
│       ├── 📄 main.tf                  # TGW, attachments, and central routing
│       ├── 📄 variables.tf
│       └── 📄 outputs.tf
│
└── 📂 environments/                    # 👑 ROOT MODULE (Where execution happens)
    └── 📂 Prod/
        ├── 📄 providers.tf             # AWS provider configuration
        ├── 📄 main.tf                  # Main orchestrator linking modules together
        ├── 📄 variables.tf             # Dev environment input values
        ├── 📄 terraform.tfvars         # REAL values, Staging env, and custom metadata tags
        └── 📄 outputs.tf               # Final configuration outputs
```
----

 ### 👑 5. Detailed Explanation of Root (Parent) Files

 ### 1️⃣ `providers.tf` (The Cloud Connector):

 This file establishes the connection between Terraform and Amazon Web Services (AWS).
```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Automatically tag every resource using variables passed from tfvars!
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = var.managed_by
    }
  }
}
```

### 2️⃣ `Variables.tf` (The Input Framework):

```hcl
# 1. Metadata Variable Declarations

variable "project_name" {type   = string }
variable "environment" {type = string}
variable "managed_by" {type = string}

# Infrastructure Variable Declarations

variable "aws_region" {type = string}
variable "hub_cidr" { type = string}
variable "hub_public_subnet_cidr" {type = string}

variable "spoke1_cidr" {type = string}
variable "spoke1_private_subnet_cidr" {type = string}

variable "spoke2_cidr" {type = string}
variable "spoke2_private_subnet_cidr" {type = string}
```

### 3️⃣ `Terraform.tfvars` (The Parameter Values):
```hcl
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
```

### 4️⃣ `Main.tf` (The Core Infrastructure Logic):
```hcl
# 1. Deploy Central Hub Infrastructure(VPC HUB Module)

module "hub_network" {
  source = "../../modules/vpc_hub"
  hub_vpc_cidr  = var.hub_cidr
  public_subnet_cidr    = var.hub_public_subnet_cidr
}

# 2. Deploy Transit Gateway Router Mechanism(Trasit Gatway Module)

module "transit_gateway" {
  source = "../../modules/transit_gatway"
  hub_vpc_id    = module.hub_network.vpc_id

  vpc_attachments   = {
    hub = module.hub_network.vpc_id
    spoke_1 = module.spoke_network_1.vpc_id
    spoke_2 = module.spoke_network_2.vpc_id
    }
}

# 3. Deploy Workload Spoke VPC 1(VPC Spoke Module)

module "spoke_network_1" {
    source = "../../modules/vpc_spoke"
    spoke_name  = "${var.project_name}-spoke-1"
    spoke_vpc_cidr  =   var.spoke1_cidr
    private_subnet_cidr = var.spoke1_private_subnet_cidr
    tgw_id  =   module.transit_gateway.tgw_id
}

# 4. Deploy Workload Spoke VPC 2(VPC Spoke Module)

module "spoke_network_2" {
  source = "../../modules/vpc_spoke"
  spoke_name ="${var.project_name}-spoke-2"
  spoke_vpc_cidr    = var.spoke2_cidr
  private_subnet_cidr   = var.spoke2_private_subnet_cidr
  tgw_id    = module.transit_gateway.tgw_id
}
```
### 5️⃣ `outputs.tf` (The Post-Deployment Print):
```hcl
output "deployed_hub_vpc" {
  value       = module.hub_network.vpc_id
  description = "The central hub identifier"
}

output "deployed_transit_gateway" {
  value       = module.transit_gateway.tgw_id
  description = "The core cloud router hub mesh ID"
}
```
### Notes:
### ❓ What it is:

- _While variables.tf defines the structure and types of variables your configuration expects, the terraform.tfvars file is where you feed the actual, real-world values (like specific IP CIDR blocks and regions) into those variables._

### 🎯 Why we use it:

- _Code Reusability: It allows you to use the exact same root main.tf and variables.tf files for different environments. If you want to deploy a prod environment later, you simply create a prod.tfvars file with different IP blocks—no code changes required!_
- _Security & Git Practices: In real-world teams, .tfvars files containing sensitive entries are kept out of source control, ensuring environment secrets are never leaked to public repositories._

### 🔑 Key Details for Cloud Interviews:

- _IP Schema Control: Explain to interviewers that you isolated the IP addressing parameters into a dedicated terraform.tfvars file to prevent overlapping subnets and enforce a strict, readable network allocation structure across environments._

- _Dynamic Variable Tag Injection: Highlight to hiring managers that you feed organizational governance controls (project_name, environment) as parameterized inputs directly to the AWS provider block. This showcases production-grade architecture patterns where configuration values are completely distinct from code rules._

---

### 👶 6. The Child Modules Configuration

### 🏢 Part A: The Hub Network Module `(modules/vpc_hub/)`:

This module provisions the central ingress/egress network containing your public subnet, Internet Gateway, and NAT Gateway.

### 1️⃣ `Main.tf` (VPC_hub Child Module):
```hcl
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
  vpc_id = aws_vpc_hub.id
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
  vpc_id = aws.vpc.hub.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw
  }

  tags = {Name  =   "hub-public-rt"}
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

### 2️⃣ `Variables.tf` (VPC_hub Child Module):
```hcl
variable "hub_vpc_cidr" {
  type = string
  description = "CIDR block allocated for Hub VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block allocated for Hub Public Subnet"
}
```

### 3️⃣ `outputs.tf` (VPC_hub Child Module):
```hcl
output "vpc_id" {
  value       = aws_vpc.hub.id
  description = "The ID of the generated Hub VPC"
}
```
------
