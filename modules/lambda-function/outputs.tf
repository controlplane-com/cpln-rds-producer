output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.lambda_update_ips.arn
}

output "lambda_security_group_id" {
  description = "Lambda security group ID"
  value       = aws_security_group.lambda.id
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.lambda_update_ips.function_name
}

output "lambda_role_arn" {
  description = "Lambda IAM role ARN"
  value       = aws_iam_role.cpln_private_link_role.arn
}

output "cloudwatch_rule_arn" {
  description = "CloudWatch event rule ARN"
  value       = aws_cloudwatch_event_rule.every_minute.arn
} 