# modules/application/ec2-backend.tf

resource "aws_instance" "backend-ec2" {
  ami                    = data.aws_ami.ubuntu.id  # Reuse from frontend
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private-subnet.id  # ← Private subnet (no public IP!)
  vpc_security_group_ids = [aws_security_group.backend.id]  # ← Backend SG (allows port 3000 from frontend)
  key_name               = aws_key_pair.app.key_name
  
  # Backend is in private subnet → NO public IP
  associate_public_ip_address = false

  # Attach IAM role for S3 logging (same as frontend)
  iam_instance_profile = aws_iam_instance_profile.ec2_logs.name

  # Pass RDS details + S3 bucket to user_data
  user_data = templatefile("${path.module}/user-data/backend.sh.tftpl", {
    rds_host     = aws_db_instance.app.address
    rds_dbname   = aws_db_instance.app.db_name
    rds_username = aws_db_instance.app.username
    rds_password = aws_db_instance.app.password
    s3_log_bucket = aws_s3_bucket.app_logs.bucket
    app_port     = var.app_port  # ← Port 3000 (or your custom port)
  })

  user_data_replace_on_change = true

  # Explicit dependency on RDS (for practice)
  depends_on = [
    aws_db_instance.app,
    aws_s3_bucket.app_logs,
    aws_iam_instance_profile.ec2_logs
  ]

  tags = {
    Name = "infrawave-backend"
  }
}

# Output backend private IP (for frontend to connect)
output "backend_private_ip" {
  value = aws_instance.backend-ec2.private_ip
}