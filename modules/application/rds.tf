# modules/application/rds.tf

resource "aws_db_instance" "app" {
  identifier = "infrawave-app-db"

  # Database engine
  engine         = "postgres"
  engine_version = "14.9"
  
  # Instance size (Free Tier eligible: db.t3.micro)
  instance_class = "db.t3.micro"
  
  # Storage
  allocated_storage = 20  # GB
  storage_type      = "gp2"
  storage_encrypted = true  # 🔒 Always encrypt databases!

  # Network placement
  db_subnet_group_name = aws_db_subnet_group.app.name
  vpc_security_group_ids = [aws_security_group.rds.id]  # ← RDS SG (only allows backend SG)

  # Credentials (will be overridden by secrets.tf)
  username = "appuser"
  password = random_password.rds.result  # ← Generated in secrets.tf

  # Database name
  db_name = "appdb"

  # Backup & maintenance
  backup_retention_period = 7  # Days
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Skip final snapshot on destroy (for testing)
  skip_final_snapshot = true

  # Explicit dependency on networking
  depends_on = [
    aws_subnet.private-subnet,
    aws_security_group.rds
  ]

  tags = {
    Name = "infrawave-app-db"
  }
}

# RDS Subnet Group (required for multi-AZ placement)
resource "aws_db_subnet_group" "app" {
  name       = "infrawave-app-db-subnet-group"
  subnet_ids = [aws_subnet.private-subnet.id]  # Single subnet for simplicity

  tags = {
    Name = "infrawave-app-db-subnet-group"
  }
}

# Output RDS endpoint (for backend to connect)
output "rds_endpoint" {
  value = aws_db_instance.app.endpoint
}