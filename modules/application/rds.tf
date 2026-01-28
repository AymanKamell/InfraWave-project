# modules/application/rds.tf

resource "aws_db_instance" "app" {
  identifier = "infrawave-app-db"

  engine         = "postgres"
  engine_version = "14.9"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [var.rds_sg_id]  # ✅ USE VARIABLE

  username = "appuser"
  password = random_password.rds.result
  db_name  = "appdb"

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  skip_final_snapshot     = true

  tags = {
    Name = "infrawave-app-db"
  }
}

resource "aws_db_subnet_group" "app" {
  name       = "infrawave-app-db-subnet-group"
  subnet_ids = [var.private_subnet_id]  # ✅ USE VARIABLE

  tags = {
    Name = "infrawave-app-db-subnet-group"
  }
}
