

# InfraWave: Production-Ready 3-Tier AWS Architecture

![Terraform](https://img.shields.io/badge/Terraform-1.5%2B-blue?logo=terraform)
![Ansible](https://img.shields.io/badge/Ansible-2.10%2B-orange?logo=ansible)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-543774?logo=ubuntu)
![Free Tier](https://img.shields.io/badge/Free_Tier_Eligible-Yes-brightgreen)

A secure, production-ready 3-tier web application architecture deployed entirely through Infrastructure-as-Code. Built with **Terraform** for infrastructure provisioning and **Ansible** for robust configuration management — replacing fragile user-data scripts with idempotent, testable playbooks.

## 🌐 Architecture Overview

 <img width="1004" height="261" alt="image" src="https://github.com/user-attachments/assets/668b03f5-5940-4a5f-9dd1-e30a496e243f" />


```
Internet Users
       │
       ▼
┌──────────────┐
│  FRONTEND    │  Public Subnet (us-east-1a)
│   EC2        │  • Nginx web server (port 80)
│  (nginx)     │  • Public IP address
└──────┬───────┘
       │ HTTP/HTTPS
       ▼
┌──────────────┐    ┌──────────────┐
│   BASTION    │    │   BACKEND    │  Private Subnet (us-east-1a)
│    EC2       │    │    EC2       │  • Flask API (port 3000)
│  (SSH Jump)  │◄──►│  (Flask API) │  • No public IP
└──────────────┘    └──────┬───────┘
                           │ PostgreSQL (port 5432)
                           ▼
                    ┌──────────────┐
                    │     RDS      │  Private Subnet (us-east-1b)
                    │  PostgreSQL  │  • Encrypted storage
                    │   (Single-AZ)│  • Multi-AZ compliant subnet group
                    └──────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  S3 LOGS     │  Centralized encrypted storage
                    │   BUCKET     │  • Automatic lifecycle policies
                    └──────────────┘
```

## ✨ Key Achievements

✅ **True Production-Ready Design**
- Multi-AZ compliant RDS subnet group meeting AWS requirements without Multi-AZ costs
- Least-privilege security groups using security group references (not CIDR blocks)
- Bastion host pattern for secure private subnet access
- NAT Gateway enabling private instances to download OS updates securely

✅ **Robust Configuration Management**
- Replaced fragile user-data scripts with **idempotent Ansible playbooks**
- Playbooks handle nginx setup, Flask API deployment, and log shipping configuration
- Zero secrets hardcoded — RDS credentials injected via AWS Secrets Manager at runtime
- IAM roles enable secure S3 log shipping without storing AWS keys on instances

✅ **Cost-Optimized for Learning & Production**
- All resources Free Tier eligible (`t3.micro` instances, `db.t3.micro` RDS)
- Single-AZ RDS deployment (`multi_az = false`) while maintaining AWS compliance
- S3 lifecycle policies automatically transition logs to cost-effective storage tiers

✅ **Enterprise Security Patterns**
- SSH access strictly limited to your IP address (`admin_ip` variable)
- Database never exposed to the internet — accessible only from backend security group
- S3 bucket with public access blocked and server-side encryption enabled
- EC2 instances hardened via Ansible (password authentication disabled)

## 📁 Project Structure

```
InfraWave-project/
├── main.tf                 # Root module composition
├── variables.tf            # Root variables declaration
├── terraform.tfvars.example# Template for your configuration
├── .gitignore              # Excludes secrets and state files
├── backend.tf              # Remote state in S3 with locking
│
├── modules/
│   ├── networking/         # VPC foundation (3 subnets, SGs, NACLs, routing)
│   └── application/        # EC2 instances, RDS, S3 logs, IAM roles
│       ├── ec2-frontend.tf # Public nginx server
│       ├── ec2-backend.tf  # Private Flask API server
│       ├── ec2-bastion.tf  # SSH jump host for secure access
│       ├── rds.tf          # PostgreSQL database
│       └── ...             # Supporting resources
│
└── playbooks/              # Ansible configuration management
    ├── frontend.yml        # Nginx setup + log shipping configuration
    └── backend.yml         # Flask API deployment + systemd service
```

## 🔐 Security Architecture

| Component | Access Control | Why It Matters |
|-----------|----------------|----------------|
| **Frontend EC2** | HTTP/HTTPS open to internet<br>SSH only from your IP | Serves public traffic while protecting admin access |
| **Bastion Host** | SSH only from your IP<br>Egress only to private subnets | Single controlled entry point to private resources |
| **Backend EC2** | API port only from frontend SG<br>SSH only via bastion | Zero public exposure — invisible to internet scans |
| **RDS Database** | PostgreSQL only from backend SG | Database never internet-accessible |
| **S3 Log Bucket** | Block all public access + encryption | Prevents accidental data leaks |

## 🚀 Deployment Guide

### Prerequisites
1. AWS account with programmatic access configured (`aws configure`)
2. Terraform 1.5+ installed
3. Ansible 2.10+ installed
4. SSH key pair named `ninja` in your AWS EC2 Key Pairs

### Step 1: Configure Your Environment
```bash
git clone https://github.com/your-username/InfraWave-project.git
cd InfraWave-project

# Create your configuration file (NEVER commit this)
cp terraform.tfvars.example terraform.tfvars
```
Edit `terraform.tfvars` to set your public IP address:
```hcl
admin_ip = "YOUR.PUBLIC.IP/32"  # Run `curl ifconfig.me` on your laptop to find this
app_port = 3000
```

### Step 2: Deploy Infrastructure
```bash
terraform init    # Initialize providers and backend
terraform plan    # Preview changes (verify your IP appears in security groups)
terraform apply   # Deploy all resources (~12 minutes)
```

### Step 3: Configure Instances with Ansible
After Terraform completes, configure your instances:
```bash
# Apply frontend configuration (nginx + log shipping)
ansible-playbook -i "$(terraform output -raw frontend_public_ip)," \
  --private-key ~/.ssh/ninja.pem \
  --user ubuntu \
  playbooks/frontend.yml

# Apply backend configuration (Flask API)
ansible-playbook -i "$(terraform output -raw backend_private_ip)," \
  --private-key ~/.ssh/ninja.pem \
  --user ubuntu \
  playbooks/backend.yml
```

### Step 4: Verify Your Deployment
1. Open your browser and visit the frontend public IP (from `terraform output frontend_public_ip`)
2. You'll see a confirmation page showing:
   - ✅ Frontend server status
   - ✅ Backend API connectivity
   - ✅ Database connection status
3. SSH to your bastion host using:
   ```bash
   ssh -i ~/.ssh/ninja.pem ubuntu@$(terraform output -raw bastion_public_ip)
   ```

## 🔑 Access Patterns

| Resource | How to Access | Port |
|----------|---------------|------|
| **Frontend Web App** | Directly via browser | 80 (HTTP) |
| **Bastion Host** | SSH from your laptop | 22 |
| **Backend API** | Via bastion host or frontend proxy | 3000 |
| **RDS Database** | Only from backend EC2 | 5432 |

> 💡 **Security Note**: Backend and database resources have **no public IP addresses** — they can only be accessed through the bastion host or frontend security group.

## ♻️ Cleanup

To avoid unexpected charges, always destroy your infrastructure when not in use:
```bash
terraform destroy
```
This safely removes all resources including RDS databases and EC2 instances.

## 💡 Why This Architecture Matters

This project demonstrates **production-grade cloud patterns** used by enterprises worldwide:

- **Security-first design**: No resource has unnecessary public exposure
- **Infrastructure-as-Code**: Entire environment reproducible in 12 minutes
- **Configuration management**: Ansible playbooks replace fragile boot scripts
- **Cost consciousness**: Free Tier eligible while maintaining production readiness
- **Operational excellence**: Centralized logging, secure access patterns, and audit trails
