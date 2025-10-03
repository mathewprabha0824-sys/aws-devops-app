# aws-devops-assessment
Overview
This project demonstrates a complete AWS infrastructure setup using Infrastructure as Code (Terraform), Configuration Management (Ansible), and CI/CD automation. The solution provides a highly available, scalable web application deployment following DevOps best practices.
Architecture Overview
Infrastructure Components
•	VPC: Custom VPC with public and private subnets across 2 availability zones (ap-south-1a, ap-south-1b)
•	Web Tier: 2 EC2 instances (t2.micro) running Apache/PHP in public subnets
•	Application Tier: 1 EC2 instance (t2.micro) in private subnet
•	Load Balancer: Application Load Balancer distributing traffic across web servers
•	Database: RDS MySQL instance (db.t3.micro) with Multi-AZ deployment in private subnet
•	Storage: S3 bucket for application assets with versioning enabled
•	Security: Security groups for web, application, and database tiers with least privilege access
Architecture Diagram
Internet
    |
    v
[Application Load Balancer]
    |
    +-------------------+
    |                   |
    v                   v
[Web Server 1]     [Web Server 2]
(Public Subnet)    (Public Subnet)
    |                   |
    +-------------------+
            |
            v
    [App Server]
    (Private Subnet)
            |
            v
    [RDS MySQL]
    (Private Subnet)
File structure:
aws-devops-assessment—
----Terraform
----------main.tf
----------output.tf
----------variables.tf # 
----------devops-key.pem
----Ansible
--------Inventory
-------------hosts.ini
--------playbooks
--------------web-server.yml
--------------app-server.yml
----pipeline
---------scripts
------------simple-deploy.sh
-------------rollback.sh
----webapp
---------index.php
---------health.php
Prerequisites
•	AWS Account with appropriate permissions
•	Terraform v1.0+
•	Ansible 2.16+ (compatible with Python 3.7)
•	SSH key pair for EC2 access
•	AWS CLI configured
Setup Instructions
1.	Infrastructure Provisioning (Terraform)
In single main.tf file installed all modules
cd terraform

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply infrastructure
terraform apply -auto-approve

# Save outputs
terraform output > outputs.txt
Key Resources Created:
•	VPC with CIDR 10.0.0.0/16
•	2 public subnets and 2 private subnets
•	Internet Gateway and NAT Gateway
•	2 web servers with Auto Scaling Group
•	Application Load Balancer
•	RDS MySQL database
•	S3 bucket with versioning
2. Configuration Management (Ansible)
cd ../ansible

# Test connectivity
ansible -i inventory/hosts.ini web_servers -m ping

# Run web server configuration
ansible-playbook -i inventory/hosts.ini playbooks/web-server.yml

# Run application server configuration (optional)
ansible-playbook -i inventory/hosts.ini playbooks/app-server.yml

# Or run complete site playbook
ansible-playbook -i inventory/hosts.ini playbooks/site.yml
What Ansible Configures:
•	Installs Apache, PHP, and dependencies
•	Deploys web application
•	Configures Apache for performance
•	Implements security hardening
•	Sets up health check endpoints
3. CI/CD Pipeline Deployment
cd ../pipeline/scripts

# Make script executable
chmod +x simple-deploy.sh

# Deploy application
./simple-deploy.sh 1.0.0 staging

# For production deployment
./simple-deploy.sh 1.0.1 production
Pipeline Features:
•	Automated build process
•	PHP syntax validation
•	Multi-server deployment
•	Health check verification
•	Deployment logging
•	Rollback capability
Access Points
After successful deployment, access your application at:

Security Considerations
Implemented Security Measures
1.	Network Isolation
o	Application and database servers in private subnets
o	Web servers in public subnets with controlled access
o	NAT Gateway for outbound private subnet traffic
2.	Security Groups
o	Web tier: Allows HTTP (80) and SSH (22)
o	App tier: Only accessible from web tier
o	Database tier: Only accessible from app tier on port 3306
3.	Access Control
o	SSH key-based authentication
o	No password authentication enabled
o	Bastion host pattern for private subnet access
4.	Application Security
o	Apache security hardening (ServerTokens, ServerSignature)
o	Directory listing disabled
o	PHP input sanitization with htmlspecialchars()
5.	Database Security
o	RDS in private subnet
o	Encryption at rest enabled
o	Automated backups configured
o	Multi-AZ for high availability
Security Best Practices Applied
•	Least privilege IAM policies
•	Security group rules follow principle of least privilege
•	SSH keys not committed to version control
•	Environment variables for sensitive configuration
•	Regular security updates through package management
Cost Optimization Strategies
Current Implementation
1.	Instance Sizing
o	Using t2.micro instances (Free Tier eligible)
o	Right-sized for development/testing workload
2.	Database Optimization
o	db.t3.micro for RDS (smallest production-ready size)
o	Automated backups with 7-day retention
o	Multi-AZ only for production environments
3.	Storage Optimization
o	S3 with lifecycle policies
o	EBS volumes with gp3 type (cost-effective)
Troubleshooting Guide
Common Issues and Solutions
Issue 1: Cannot connect to EC2 instances
# Verify security group allows SSH from your IP
terraform state show aws_security_group.web_sg

# Ensure SSH key has correct permissions
chmod 400 terraform/devops-key.pem

# Test connection
ssh -i terraform/devops-key.pem ec2-user@<instance-ip>
Issue 2: Website not accessible
# Check Apache status
ssh -i terraform/devops-key.pem ec2-user@<instance-ip> "sudo systemctl status httpd"

# Test locally on server
ssh -i terraform/devops-key.pem ec2-user@<instance-ip> "curl http://localhost"

# Verify security group allows HTTP
# Add rule if missing:
# Ingress: Port 80, Source: 0.0.0.0/0
Issue 3: Ansible connection failures
# Verify Python version on remote hosts
ansible -i ansible/inventory/hosts.ini web_servers -m raw -a "python3 --version"

# Test connectivity
ansible -i ansible/inventory/hosts.ini web_servers -m ping

# Check SSH key path in inventory
cat ansible/inventory/hosts.ini
Issue 4: Load balancer health checks failing
# Check target group health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Verify health check endpoint
curl http://<instance-ip>/health.php

# Check Apache error logs
ssh -i terraform/devops-key.pem ec2-user@<instance-ip> "sudo tail -f /var/log/httpd/error_log"

Testing and Validation
Infrastructure Tests
# Verify all resources created
cd terraform
terraform state list

# Check outputs
terraform output

# Validate configuration
terraform validate
# Run deployment script
cd pipeline/scripts
./simple-deploy.sh 1.0.0 staging

# Expected output:
# ✓ Build completed
# ✓ Tests passed
# ✓ Deployed to all servers
# ✓ Health checks passed
