# modules/application/rds.tf - CORRECTED SYNTAX + MULTI-AZ FIX

# RDS Subnet Group (MUST span 2 AZs for AWS requirement)
resource "aws_db_subnet_group" "app" {
  name       = "infrawave-app-db-subnet-group"
  subnet_ids = [
    var.private_subnet_id,    # us-east-1a
    var.private_subnet_2_id   # us-east-1b (critical for RDS)
  ]

  tags = {
    Name = "infrawave-app-db-subnet-group"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "app" {
  identifier = "infrawave-app-db"

  engine         = "postgres"
  engine_version = "14"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  # Reference the subnet group (separate resource)
  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [var.rds_sg_id]

  username = "appuser"
  password = random_password.rds.result
  db_name  = "appdb"

  backup_retention_period = 7
  skip_final_snapshot     = true

  # Explicitly disable multi-AZ (we only need 2-AZ subnet group requirement)
  multi_az = false

  tags = {
    Name = "infrawave-app-db"
  }
}
