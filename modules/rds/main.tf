module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "rds-instance"

  # Engine configuration
  engine               = "postgres"
  engine_version       = "15.12"
  family               = "postgres15"
  instance_class       = var.rds_instance_class
  allocated_storage    = var.rds_allocated_storage

  # Credentials
  db_name  = "postgres"
  username = var.db_username
  password = var.db_password
  port     = "5432"

  # Networking
  subnet_ids = var.subnet_ids

  # Security group will be auto-created by the module

  # High availability
  multi_az = true

  # Storage
  storage_type      = "gp2"
  storage_encrypted = true

  # Backup and maintenance
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

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