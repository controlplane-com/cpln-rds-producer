output "mode" {
  description = "Current operation mode (auto-detected or explicitly set)"
  value       = local.create_infrastructure ? "Provisioning new infrastructure" : "Using existing infrastructure"
}

output "auto_detection_details" {
  description = "Details about how the mode was determined"
  value = {
    explicit_setting = var.create_infrastructure
    auto_detected    = local.auto_create_infrastructure
    final_mode       = local.create_infrastructure
    db_instance_arn_provided = var.db_instance_arn != null
    secret_arn_provided      = var.secret_arn != null
  }
}

output "privatelink_service_name" {
  description = "PrivateLink Endpoint Service Name"
  value       = module.vpc_endpoint.service_name
}

output "region" {
  description = "AWS region"
  value       = local.aws_region
}

# Testing/Debugging Outputs
output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = module.lambda_function.lambda_function_arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda_function.lambda_function_name
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = module.load_balancer.target_group_arn
}

output "nlb_dns_name" {
  description = "Network Load Balancer DNS name"
  value       = module.load_balancer.nlb_dns_name
}

output "rds_proxy_endpoint" {
  description = "RDS Proxy endpoint"
  value       = module.rds_proxy.proxy_endpoint
}