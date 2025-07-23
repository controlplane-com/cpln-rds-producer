variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "secret_arn" {
  description = "Secrets Manager ARN"
  type        = string
}

variable "db_instance_identifier" {
  description = "RDS instance identifier"
  type        = string
} 