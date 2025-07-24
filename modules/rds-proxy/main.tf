# RDS Proxy Security Group
resource "aws_security_group" "rds_proxy" {
  name        = "rds-proxy-sg"
  description = "Security group for RDS Proxy"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rds-proxy-sg"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

# IAM Role for RDS Proxy
resource "aws_iam_role" "rds_proxy_role" {
  name = "rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "rds-proxy-role"
  }
}

resource "aws_iam_role_policy" "rds_proxy_policy" {
  name = "rds-proxy-policy"
  role = aws_iam_role.rds_proxy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = var.secret_arn
    }]
  })
}

# RDS Proxy
resource "aws_db_proxy" "proxy" {
  name                   = "rds-proxy"
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy_role.arn
  vpc_security_group_ids = [aws_security_group.rds_proxy.id]
  vpc_subnet_ids         = var.subnet_ids
  
  auth {
    auth_scheme = "SECRETS"
    secret_arn  = var.secret_arn
    iam_auth    = "DISABLED"
  }

  tags = {
    Name        = "rds-proxy"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

# RDS Proxy Default Target Group (created automatically)
# The target group is created automatically when the proxy is created
# and targets are added via the aws_db_proxy_default_target_group resource 