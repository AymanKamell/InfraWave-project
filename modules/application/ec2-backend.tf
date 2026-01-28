# modules/application/ec2-backend.tf

resource "aws_instance" "backend-ec2" {
  ami                    = data.aws_ami.ubuntu.id  # Reuse from frontend
  instance_type          = "t3.micro"
  subnet_id              = var.private_subnet_id          # ✅ USE VARIABLE (not aws_subnet.*)
  vpc_security_group_ids = [var.backend_sg_id]            # ✅ USE VARIABLE (not aws_security_group.*)
  key_name               = "ninja"
  
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.ec2_logs.name

  user_data = templatefile("${path.module}/user-data/backend.sh.tftpl", {
    rds_host     = aws_db_instance.app.address      # ✅ OK (same module!)
    rds_dbname   = aws_db_instance.app.db_name
    rds_username = aws_db_instance.app.username
    rds_password = aws_db_instance.app.password
    s3_log_bucket = aws_s3_bucket.app_logs.bucket
    app_port     = var.app_port
  })

  user_data_replace_on_change = true

  depends_on = [
    aws_db_instance.app,
    aws_s3_bucket.app_logs,
    aws_iam_instance_profile.ec2_logs
  ]

  tags = {
    Name = "infrawave-backend"
  }
}
