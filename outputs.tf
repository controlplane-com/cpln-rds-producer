output "privatelink_service_name" {
  description = "PrivateLink Endpoint Service Name for Control Plane"
  value       = module.vpc_endpoint.service_name
}