# Enterprise Hub-and-Spoke Network with Secure Inspection & Hybrid Connectivity Simulation via Terraform

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

