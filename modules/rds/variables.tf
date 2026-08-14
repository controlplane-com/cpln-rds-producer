variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block allowed to reach the database on 5432"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for RDS instance"
  type        = list(string)
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
  default     = "15.18"
}

variable "db_password_version" {
  description = "Increment to push a changed db_password to the RDS instance (write-only password versioning)"
  type        = number
  default     = 1
} 