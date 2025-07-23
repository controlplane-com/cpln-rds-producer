terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Retrieve AZ options
data "aws_availability_zones" "available" {
  state = "available"
}

# Data sources for existing RDS instance (when not creating infrastructure)
data "aws_db_instance" "existing" {
  count = var.create_infrastructure ? 0 : 1
  db_instance_identifier = local.db_instance_identifier
}

# Get subnet group from existing RDS instance
data "aws_db_subnet_group" "existing" {
  count = var.create_infrastructure ? 0 : 1
  name = data.aws_db_instance.existing[0].db_subnet_group
}

# Get VPC from existing RDS instance's subnet group
data "aws_vpc" "existing" {
  count = var.create_infrastructure ? 0 : 1
  id = data.aws_db_subnet_group.existing[0].vpc_id
}

# Local values to simplify conditional logic
locals {
  # Extract RDS instance identifier from ARN
  db_instance_identifier = var.create_infrastructure ? null : split(":", var.db_instance_arn)[6]
  
  # If creating infrastructure, use module outputs; otherwise use data sources
  vpc_id      = var.create_infrastructure ? module.infrastructure[0].vpc_id : data.aws_vpc.existing[0].id
  subnet_ids  = var.create_infrastructure ? module.infrastructure[0].subnet_ids : data.aws_db_subnet_group.existing[0].subnet_ids
  vpc_cidr    = var.create_infrastructure ? var.vpc_cidr : data.aws_vpc.existing[0].cidr_block
  secret_arn  = var.create_infrastructure ? module.infrastructure[0].secret_arn : var.secret_arn
}

# Step 1: Infrastructure (conditional)
# If creating infrastructure, generate VPC, subnets, and Secrets Manager secret
module "infrastructure" {
  count  = var.create_infrastructure ? 1 : 0
  source = "./modules/infrastructure"

  vpc_cidr     = var.vpc_cidr
  vpc_name     = var.vpc_name
  subnet_1_name = var.subnet_1_name
  subnet_2_name = var.subnet_2_name
  db_username  = var.db_username
  db_password  = var.db_password
}

# Step 2: RDS Instance (conditional)
# If creating infrastructure, create new RDS instance; otherwise use existing one
module "rds" {
  count  = var.create_infrastructure ? 1 : 0
  source = "./modules/rds"

  vpc_id               = local.vpc_id
  subnet_ids           = local.subnet_ids
  db_username          = var.db_username
  db_password          = var.db_password
  instance_class       = var.rds_instance_class
  allocated_storage    = var.rds_allocated_storage
  engine_version       = var.rds_engine_version
}

# Step 3: RDS Proxy (required)
# Creates RDS Proxy to handle connection pooling and failover
module "rds_proxy" {
  source = "./modules/rds-proxy"

  vpc_id                 = local.vpc_id
  vpc_cidr               = local.vpc_cidr
  subnet_ids             = local.subnet_ids
  secret_arn             = local.secret_arn
  db_instance_identifier = var.create_infrastructure ? module.rds[0].db_instance_identifier : local.db_instance_identifier
}

# Step 4: Load Balancer (required)
# Creates Network Load Balancer to distribute traffic to RDS Proxy
module "load_balancer" {
  source = "./modules/load-balancer"

  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids
}

# Step 5: VPC Endpoint Service (required)
# Creates PrivateLink endpoint service for cross-account access
module "vpc_endpoint" {
  source = "./modules/vpc-endpoint"

  nlb_arn                 = module.load_balancer.nlb_arn
  allowed_principal_arn   = var.allowed_principal_arn
} 