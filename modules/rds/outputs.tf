output "db_instance_identifier" {
  description = "RDS instance identifier"
  value       = module.rds.db_instance_identifier
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_arn" {
  description = "RDS instance ARN"
  value       = module.rds.db_instance_arn
} 