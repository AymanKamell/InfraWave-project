resource "random_password" "rds" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "rds" {
  name = "infrawave/rds-credentials-${random_id.bucket_suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id     = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = aws_db_instance.app.username
    password = random_password.rds.result
    host     = aws_db_instance.app.address
    dbname   = aws_db_instance.app.db_name
  })
}
