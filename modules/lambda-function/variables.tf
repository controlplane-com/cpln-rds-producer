variable "aws_region" {
  description = "AWS region for Lambda deployment"
  type        = string
}

variable "target_group_arn" {
  description = "Target Group ARN from load balancer module"
  type        = string
}

variable "rds_proxy_endpoint" {
  description = "RDS Proxy endpoint to resolve"
  type        = string
}

variable "lambda_function_name" {
  description = "Name for the Lambda function"
  type        = string
  default     = "cpln_update_target_group_ips"
}

variable "dns_nameserver" {
  description = "DNS nameserver to use for resolution"
  type        = string
  default     = "169.254.169.253"  # AWS internal DNS
}

variable "vpc_id" {
  description = "VPC ID for Lambda security group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for Lambda VPC configuration"
  type        = list(string)
} 