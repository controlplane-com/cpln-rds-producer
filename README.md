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

## Required Inputs

### For New Infrastructure:
```hcl
module "rds_producer" {
  source = "./modules"
  
  allowed_principal_arn = "arn:aws:iam::123456789012:root"
  aws_region = "us-west-2"
  db_username = "admin"
  db_password = "SecurePassword123!"
}
```

### For Existing Infrastructure:
```hcl
module "rds_producer" {
  source = "./modules"
  
  allowed_principal_arn = "arn:aws:iam::123456789012:root"
  db_instance_arn = "arn:aws:rds:us-west-2:123456789012:db:my-db"
  secret_arn = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-secret"
}
```

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
allowed_principal_arn = "arn:aws:iam::123456789012:root"
aws_region = "us-west-2"
db_username = "admin"
db_password = "SecurePassword123!"
```

**terraform.tfvars (Existing Infrastructure):**
```hcl
allowed_principal_arn = "arn:aws:iam::123456789012:root"
db_instance_arn = "arn:aws:rds:us-west-2:123456789012:db:my-db"
secret_arn = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-secret"
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
  
  allowed_principal_arn = var.allowed_principal_arn
  aws_region = var.aws_region
  db_username = var.db_username
  db_password = var.db_password
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

## Cost Estimate

**New Infrastructure:** ~$53/month (RDS + Proxy + NLB + Secrets)
**Existing Infrastructure:** ~$38/month (Proxy + NLB only)

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review AWS documentation
3. Open an issue in this repository