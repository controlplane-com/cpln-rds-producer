output "privatelink_service_name" {
  description = "PrivateLink Endpoint Service Name"
  value       = module.vpc_endpoint.service_name
}

output "mode" {
  description = "Current operation mode"
  value       = var.create_infrastructure ? "Provisioning new infrastructure" : "Using existing infrastructure"
}