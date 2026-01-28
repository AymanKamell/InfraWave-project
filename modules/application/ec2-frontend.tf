# modules/application/ec2-frontend.tf

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "frontend-ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id          # ✅ USE VARIABLE (not aws_subnet.*)
  vpc_security_group_ids = [var.frontend_sg_id]          # ✅ USE VARIABLE (not aws_security_group.*)
  key_name               = aws_key_pair.app.key_name
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_logs.name

  user_data = templatefile("${path.module}/user-data/frontend.sh.tftpl", {
    backend_private_ip = aws_instance.backend-ec2.private_ip  # ✅ OK (same module!)
    app_port           = var.app_port
    s3_log_bucket      = aws_s3_bucket.app_logs.bucket        # ✅ OK (same module!)
  })

  user_data_replace_on_change = true

  depends_on = [
    aws_s3_bucket.app_logs,
    aws_iam_instance_profile.ec2_logs
  ]

  tags = {
    Name = "infrawave-frontend"
  }
}
