variable "nlb_arn" {
  description = "Network Load Balancer ARN"
  type        = string
}

variable "allowed_principal_arn" {
  description = "ARN of the principal allowed to connect to the VPC Endpoint Service"
  type        = string
} 