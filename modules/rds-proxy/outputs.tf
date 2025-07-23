output "proxy_endpoint" {
  description = "RDS Proxy endpoint"
  value       = aws_db_proxy.proxy.endpoint
}

output "proxy_arn" {
  description = "RDS Proxy ARN"
  value       = aws_db_proxy.proxy.arn
}

output "proxy_name" {
  description = "RDS Proxy name"
  value       = aws_db_proxy.proxy.name
}

output "proxy_role_arn" {
  description = "RDS Proxy IAM role ARN"
  value       = aws_iam_role.rds_proxy_role.arn
}

output "proxy_security_group_id" {
  description = "RDS Proxy security group ID"
  value       = aws_security_group.rds_proxy.id
} 