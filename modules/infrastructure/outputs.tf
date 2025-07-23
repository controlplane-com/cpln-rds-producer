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

 