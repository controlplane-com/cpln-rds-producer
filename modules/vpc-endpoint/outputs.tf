output "service_name" {
  description = "Service name to use for creating VPC Endpoint on consumer side"
  value       = aws_vpc_endpoint_service.rds_proxy_service.service_name
}

output "service_arn" {
  description = "VPC Endpoint Service ARN"
  value       = aws_vpc_endpoint_service.rds_proxy_service.arn
}

output "service_id" {
  description = "VPC Endpoint Service ID"
  value       = aws_vpc_endpoint_service.rds_proxy_service.id
} 