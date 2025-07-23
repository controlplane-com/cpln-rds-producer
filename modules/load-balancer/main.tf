# Target Group
resource "aws_lb_target_group" "rds_proxy_tg" {
  name        = "rds-proxy-tg"
  port        = 5432
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = "5432"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = {
    Name = "rds-proxy-tg"
  }
}

# Network Load Balancer
resource "aws_lb" "rds_proxy_nlb" {
  name               = "rds-proxy-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "rds-proxy-nlb"
  }
}

# NLB Listener
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.rds_proxy_nlb.arn
  port              = 5432
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rds_proxy_tg.arn
  }
}

# Note: Target group attachment will be handled by Lambda function
# The Lambda function will dynamically register the RDS Proxy IP
# resource "aws_lb_target_group_attachment" "rds_proxy_attachment" {
#   target_group_arn = aws_lb_target_group.rds_proxy_tg.arn
#   target_id        = aws_db_proxy.proxy.endpoint  # Use lambda resolved IP
#   port             = 5432
# } 