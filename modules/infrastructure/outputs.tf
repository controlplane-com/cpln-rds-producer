output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}


output "secret_arn" {
  description = "Secrets Manager ARN"
  value       = aws_secretsmanager_secret.db_secret.arn
}

 
output "elbv2_endpoint_id" {
  description = "ELBv2 VPC Endpoint ID"
  value       = aws_vpc_endpoint.elbv2.id
}

output "cloudwatch_logs_endpoint_id" {
  description = "CloudWatch Logs VPC Endpoint ID"
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "cloudwatch_monitoring_endpoint_id" {
  description = "CloudWatch Monitoring VPC Endpoint ID"
  value       = aws_vpc_endpoint.cloudwatch_monitoring.id
}

 