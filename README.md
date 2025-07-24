# Control Plane RDS Producer Terraform Modules

Terraform modules for creating an RDS Producer infrastructure with PrivateLink endpoint service for Control Plane connectivity. Works with existing infrastructure or creates new resources.

## What Gets Created

### Create Infrastructure Mode (no ARNs provided):
- **VPC & Subnets** - Private networking for RDS
- **RDS Instance** - PostgreSQL database with multi-AZ
- **Secrets Manager** - Secure credential storage
- **RDS Proxy** - Connection pooling and failover
- **Network Load Balancer** - Traffic distribution
- **Lambda Function** - Dynamic IP updates
- **PrivateLink Endpoint Service** - Control Plane cross-account access

### Existing Infrastructure Mode (ARNs provided):
- **RDS Proxy** - Connection pooling and failover
- **Network Load Balancer** - Traffic distribution  
- **Lambda Function** - Dynamic IP updates
- **PrivateLink Endpoint Service** - Control Plane cross-account access

## Prerequisites

Before running these Terraform modules, ensure you have the following:

### **Required Software:**
- **Terraform** >= 1.0 ([Download](https://www.terraform.io/downloads.html))
- **AWS CLI** >= 2.0 ([Download](https://aws.amazon.com/cli/))
- **Git** (for cloning the repository)

### **AWS Account Requirements:**
- **Active AWS Account** with billing enabled
- **AWS IAM User/Role** with appropriate permissions (see below)
- **AWS Region** where you want to deploy resources

### **Required AWS Permissions:**
Your AWS credentials must have permissions for:
- **EC2**: Create VPC, subnets, security groups, load balancers
- **RDS**: Create/modify RDS instances, proxies, parameter groups
- **Secrets Manager**: Create/read secrets
- **Lambda**: Create functions, roles, and CloudWatch triggers
- **IAM**: Create roles and policies
- **VPC Endpoints**: Create endpoint services
- **CloudWatch**: Create event rules and logs

### **For Existing Infrastructure Mode:**
- **RDS Instance** already created and available
- **Secrets Manager Secret** with database credentials in JSON format
- **VPC and Subnets** where RDS instance is located

### **Network Requirements:**
- **VPC** with private subnets (for new infrastructure mode)
- **Internet connectivity** for Terraform to download providers
- **DNS resolution** enabled in VPC

### **Cost Considerations:**
- **RDS Instance**: ~$15-50/month depending on instance type
- **RDS Proxy**: ~$20/month
- **Network Load Balancer**: ~$18/month
- **Lambda**: ~$1/month (minimal usage)
- **Secrets Manager**: ~$0.40/month
- **VPC Endpoints**: ~$0.01/hour per endpoint

### **Security Considerations:**
- **Database credentials** should be strong and secure
- **VPC** should be properly configured with security groups
- **Secrets Manager** should have appropriate access policies
- **IAM roles** follow least privilege principle

## Required Inputs

### For New Infrastructure:
- `aws_region` - AWS region for all resources
- `db_username` - Database username for new RDS instance  
- `db_password` - Database password for new RDS instance

### For Existing Infrastructure:
- `db_instance_arn` - ARN of existing RDS instance
- `secret_arn` - ARN of existing Secrets Manager secret with database credentials

## Why RDS Proxy and Secrets Manager Are Required

### RDS Proxy
- **Connection Pooling** - Manages database connections efficiently
- **Failover Handling** - Automatic failover to standby instance
- **Security** - IAM authentication instead of password-based auth

### Secrets Manager
- **Secure Storage** - Encrypted credential storage
- **RDS Proxy Requirement** - RDS Proxy cannot use plain-text credentials
- **Automatic Rotation** - Can rotate credentials without downtime

**Secret Format Required:**
```json
{
  "username": "your_db_username",
  "password": "your_db_password"
}
```

## Lambda Function Purpose

The Lambda function automatically:
1. **Resolves RDS Proxy endpoint** to get current IP address
2. **Updates Target Group** with the resolved IP
3. **Runs every minute** to handle IP changes
4. **Ensures traffic routing** works when proxy IP changes

**No manual setup required** - created and configured automatically.

## Getting Started

### 1. Create Configuration Files

**terraform.tfvars (New Infrastructure):**
```hcl
aws_region = "us-west-2"
db_username = "admin"
db_password = "SecurePassword123!"
# allowed_principal_arn defaults to Control Plane ARN
```

**terraform.tfvars (Existing Infrastructure):**
```hcl
db_instance_arn = "arn:aws:rds:us-west-2:123456789012:db:my-db"
secret_arn = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-secret"
# allowed_principal_arn defaults to Control Plane ARN
```

**main.tf:**
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "rds_producer" {
  source = "./modules"
  
  aws_region = var.aws_region
  db_username = var.db_username
  db_password = var.db_password
  # allowed_principal_arn defaults to Control Plane ARN
}
```

### 2. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 3. Get Outputs
```bash
terraform output
```

## Outputs and Next Steps

### Essential Outputs:
- **`privatelink_service_name`** - PrivateLink Endpoint Service Name for Control Plane
- **`mode`** - Operation mode (new vs existing infrastructure)
- **`region`** - AWS region

### What to Do Next:
1. **Copy the `privatelink_service_name`** from the outputs
2. **Provide it to Control Plane support** to create the PrivateLink endpoint
3. **Wait for endpoint creation** to complete
4. **Test connectivity** from your Control Plane environment

### Testing Outputs:
- **`lambda_function_arn`** - Monitor Lambda execution
- **`target_group_arn`** - Verify target group updates
- **`rds_proxy_endpoint`** - Test proxy connectivity

## Troubleshooting

### Common Issues:
- **"RDS Proxy cannot access Secrets Manager"** - Verify secret ARN and format
- **"RDS instance not found"** - Check ARN format and region
- **"Invalid secret format"** - Ensure JSON format with username/password

### Validation:
```bash
terraform validate
terraform plan
```

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review AWS documentation
3. Contact [support@controlplane.com](mailto:support@controlplane.com)