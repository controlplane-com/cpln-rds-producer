# RDS Producer Terraform Modules

This repository contains Terraform modules for creating an RDS Producer infrastructure with PrivateLink endpoint service. The modules are designed to be flexible and can work with existing infrastructure or create new resources as needed.

## Architecture

The infrastructure consists of the following components:

1. **Infrastructure Module** (Optional) - VPC, subnets, and Secrets Manager
2. **RDS Module** (Optional) - PostgreSQL RDS instance with multi-AZ
3. **RDS Proxy Module** (Required) - RDS Proxy with IAM authentication
4. **Load Balancer Module** (Required) - Network Load Balancer and Target Group
5. **VPC Endpoint Module** (Required) - PrivateLink endpoint service

### Auto-Discovery Feature

When using existing infrastructure (`create_infrastructure = false`), the modules automatically discover:
- **VPC ID** from the RDS instance
- **Subnet IDs** from the RDS subnet group
- **VPC CIDR** from the existing VPC

Users only need to provide the RDS instance ARN and Secrets Manager ARN.

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- AWS Provider ~> 5.0

## Usage Scenarios

### Scenario 1: Create New Infrastructure (`create_infrastructure = true`)

**Use this when:** You want to create a complete new infrastructure including VPC, subnets, RDS instance, and Secrets Manager.

**Required Inputs:**
```hcl
module "rds_producer" {
  source = "./modules"

  # Required for all scenarios
  aws_region = "us-west-2"
  allowed_principal_arn = "arn:aws:iam::123456789012:root"
  
  # Required when create_infrastructure = true
  create_infrastructure = true
  db_username = "myuser"
  db_password = "mypassword"
  
  # Optional - will use defaults if not specified
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "producer-vpc"
  subnet_1_name = "private-subnet-1"
  subnet_2_name = "private-subnet-2"
  rds_instance_class = "db.t3.micro"
  rds_allocated_storage = 20
  rds_engine_version = "15.4"
}
```

**What gets created:**
- ✅ VPC with specified CIDR
- ✅ 2 private subnets in different AZs
- ✅ Secrets Manager secret with database credentials
- ✅ PostgreSQL RDS instance with auto-created security group
- ✅ RDS Proxy with IAM authentication
- ✅ Network Load Balancer and Target Group
- ✅ PrivateLink Endpoint Service

### Scenario 2: Use Existing Infrastructure (`create_infrastructure = false`)

**Use this when:** You already have an RDS instance and want to add RDS Proxy, Load Balancer, and PrivateLink capabilities.

**Required Inputs:**
```hcl
module "rds_producer" {
  source = "./modules"

  # Required for all scenarios
  aws_region = "us-west-2"
  allowed_principal_arn = "arn:aws:iam::123456789012:root"
  
  # Required when create_infrastructure = false
  create_infrastructure = false
  db_instance_arn = "arn:aws:rds:us-west-2:123456789012:db:my-existing-rds"  # Your existing RDS instance ARN
  secret_arn = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-db-secret-xyz123"
}
```

**What gets created:**
- ❌ No VPC (uses existing)
- ❌ No subnets (uses existing)
- ❌ No RDS instance (uses existing)
- ❌ No Secrets Manager secret (uses existing)
- ✅ RDS Proxy with IAM authentication
- ✅ Network Load Balancer and Target Group
- ✅ PrivateLink Endpoint Service

**Auto-Discovery:**
The module automatically discovers:
- VPC ID from your RDS instance
- Subnet IDs from your RDS subnet group
- VPC CIDR from the existing VPC

## Variables Reference

### Required Variables (All Scenarios)

| Variable | Description | Example |
|----------|-------------|---------|
| `aws_region` | AWS region for all resources | `"us-west-2"` |
| `allowed_principal_arn` | ARN of principal allowed to connect to VPC Endpoint Service | `"arn:aws:iam::123456789012:root"` |

### Required Variables (Scenario 1: Create Infrastructure)

| Variable | Description | Example |
|----------|-------------|---------|
| `create_infrastructure` | Must be `true` | `true` |
| `db_username` | Database username for new RDS instance | `"myuser"` |
| `db_password` | Database password for new RDS instance | `"mypassword123!"` |

### Required Variables (Scenario 2: Use Existing Infrastructure)

| Variable | Description | Example |
|----------|-------------|---------|
| `create_infrastructure` | Must be `false` | `false` |
| `db_instance_arn` | Existing RDS instance ARN | `"arn:aws:rds:us-west-2:123456789012:db:my-existing-rds"` |
| `secret_arn` | Existing Secrets Manager ARN with database credentials | `"arn:aws:secretsmanager:us-west-2:123456789012:secret:my-db-secret-xyz123"` |

### Optional Variables (Scenario 1 Only)

| Variable | Description | Default |
|----------|-------------|---------|
| `vpc_cidr` | CIDR block for VPC | `"10.0.0.0/16"` |
| `vpc_name` | Name for the VPC | `"producer-vpc"` |
| `subnet_1_name` | Name for first private subnet | `"private-subnet-1"` |
| `subnet_2_name` | Name for second private subnet | `"private-subnet-2"` |
| `rds_instance_class` | RDS instance class | `"db.t3.micro"` |
| `rds_allocated_storage` | RDS allocated storage in GB | `20` |
| `rds_engine_version` | RDS engine version | `"15.4"` |

## Outputs

| Output | Description |
|--------|-------------|
| `privatelink_service_name` | PrivateLink Endpoint Service Name (use this on consumer side) |
| `mode` | Current operation mode ("Provisioning new infrastructure" or "Using existing infrastructure") |

## Lambda Function Integration

The Load Balancer module creates a Target Group without any targets. A Lambda function should be created separately to:

1. Resolve the RDS Proxy IP address
2. Register the IP in the Target Group
3. Update the target when the IP changes

## Security Features

- **RDS Security**: Auto-created security group with PostgreSQL port (5432) access
- **Encryption**: All RDS instances encrypted at rest
- **IAM Authentication**: RDS Proxy uses IAM roles for Secrets Manager access
- **PrivateLink**: VPC Endpoint Service restricts access to specified principals
- **Network Isolation**: All resources in private subnets

## Quick Start Examples

### Example 1: Create Everything
```hcl
module "rds_producer" {
  source = "./modules"
  
  aws_region = "us-west-2"
  create_infrastructure = true
  db_username = "admin"
  db_password = "SecurePassword123!"
  allowed_principal_arn = "arn:aws:iam::123456789012:root"
}
```

### Example 2: Use Existing RDS
```hcl
module "rds_producer" {
  source = "./modules"
  
  aws_region = "us-west-2"
  create_infrastructure = false
  db_instance_arn = "arn:aws:rds:us-west-2:123456789012:db:my-production-db"
  secret_arn = "arn:aws:secretsmanager:us-west-2:123456789012:secret:prod-db-credentials"
  allowed_principal_arn = "arn:aws:iam::123456789012:root"
}
```