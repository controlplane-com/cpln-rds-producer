# Security group for the RDS instance: allow PostgreSQL from within the VPC
# (the RDS Proxy lives in the same VPC and must be able to reach the database).
resource "aws_security_group" "rds" {
  name        = "rds-instance-sg"
  description = "Security group for RDS instance"
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
    Name        = "rds-instance-sg"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.0"

  identifier = "rds-instance"

  # Engine configuration
  engine            = "postgres"
  engine_version    = var.rds_engine_version
  family            = "postgres${split(".", var.rds_engine_version)[0]}"
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage

  # Credentials
  # The password is managed by this configuration (stored in our own Secrets
  # Manager secret for RDS Proxy), so RDS-managed master passwords are disabled.
  db_name                     = "postgres"
  username                    = var.db_username
  password_wo                 = var.db_password
  password_wo_version         = var.db_password_version
  manage_master_user_password = false
  port                        = "5432"

  # Networking
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]

  # High availability
  multi_az = true

  # Storage
  storage_type      = "gp3"
  storage_encrypted = true

  # Backup and maintenance
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Deletion protection for production
  deletion_protection = true
  skip_final_snapshot = false

  # Auto-create subnet group
  create_db_subnet_group = true

  tags = {
    Name        = "rds-instance"
    Environment = "production"
    Project     = "rds-producer"
    ManagedBy   = "terraform"
  }
}
