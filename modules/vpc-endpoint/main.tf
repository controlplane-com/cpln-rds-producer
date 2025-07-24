resource "aws_vpc_endpoint_service" "rds_proxy_service" {
  acceptance_required        = false
  network_load_balancer_arns = [var.nlb_arn]

  # Restrict which principals can connect
  allowed_principals = [var.allowed_principal_arn]

  tags = {
    Name        = "rds-proxy-endpoint-service"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
} 