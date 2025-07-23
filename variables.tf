variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "create_infrastructure" {
  description = "Whether to create new infrastructure (VPC, subnets, RDS) or use existing"
  type        = bool
  default     = true
}

variable "db_instance_arn" {
  description = "ARN of existing RDS instance (required when create_infrastructure = false)"
  type        = string
  default     = null
}

variable "secret_arn" {
  description = "ARN of existing Secrets Manager secret (required when create_infrastructure = false)"
  type        = string
  default     = null
}

variable "allowed_principal_arn" {
  description = "ARN of principal allowed to connect to VPC Endpoint Service"
  type        = string
  default     = "arn:aws:iam::957753459089:root"
}

# Database credentials (required when create_infrastructure = true)
variable "db_username" {
  description = "Database username"
  type        = string
  default     = null

  validation {
    condition     = var.create_infrastructure ? var.db_username != null : true
    error_message = "db_username is required when create_infrastructure = true."
  }
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.create_infrastructure ? var.db_password != null : true
    error_message = "db_password is required when create_infrastructure = true."
  }
}

# Infrastructure variables (used when create_infrastructure = true)
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
  default     = "producer-vpc"
}

variable "subnet_1_name" {
  description = "Name for the first private subnet"
  type        = string
  default     = "private-subnet-1"
}

variable "subnet_2_name" {
  description = "Name for the second private subnet"
  type        = string
  default     = "private-subnet-2"
}

# RDS variables (used when create_infrastructure = true)
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "15.4"
} 