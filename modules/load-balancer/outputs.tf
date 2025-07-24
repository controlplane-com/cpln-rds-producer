output "nlb_arn" {
  description = "Network Load Balancer ARN"
  value       = aws_lb.rds_proxy_nlb.arn
}

output "nlb_dns_name" {
  description = "Network Load Balancer DNS name"
  value       = aws_lb.rds_proxy_nlb.dns_name
}

output "target_group_arn" {
  description = "Target Group ARN for Lambda function to update"
  value       = aws_lb_target_group.rds_proxy_tg.arn
}

output "target_group_name" {
  description = "Target Group name"
  value       = aws_lb_target_group.rds_proxy_tg.name
}

output "listener_arn" {
  description = "NLB Listener ARN"
  value       = aws_lb_listener.nlb_listener.arn
}

output "region" {
  description = "AWS region extracted from NLB ARN"
  value       = split(":", aws_lb.rds_proxy_nlb.arn)[3]
} 