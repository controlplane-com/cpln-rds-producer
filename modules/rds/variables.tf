variable "vpc_id" {
  description = "VPC ID"
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

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "15.4"
} 