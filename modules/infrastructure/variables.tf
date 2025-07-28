variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
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

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for VPC endpoints"
  type        = string
}



variable "secret_name" {
  description = "Name for the Secrets Manager secret"
  type        = string
  default     = "db-credentials"
} 