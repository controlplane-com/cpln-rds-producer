# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = var.vpc_name
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

# Subnets
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = var.subnet_1_name
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = var.subnet_2_name
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

# Secrets Manager Secret
resource "aws_secretsmanager_secret" "db_secret" {
  name = var.secret_name
  
  tags = {
    Name        = "db-secret"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
} 

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.lambda_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "vpc-endpoints-sg"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

# ELBv2 VPC Endpoint
resource "aws_vpc_endpoint" "elbv2" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "elbv2-endpoint"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

# CloudWatch Logs VPC Endpoint
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "cloudwatch-logs-endpoint"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

# CloudWatch Monitoring VPC Endpoint
resource "aws_vpc_endpoint" "cloudwatch_monitoring" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.monitoring"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "cloudwatch-monitoring-endpoint"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
} 