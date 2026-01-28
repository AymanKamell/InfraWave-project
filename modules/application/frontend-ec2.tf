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
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.frontend.id]
  key_name               = aws_key_pair.app.key_name
  associate_public_ip_address = true

  # 🔑 Attach IAM role for S3 access
  iam_instance_profile = aws_iam_instance_profile.ec2_logs.name

  # 📦 Pass bucket name to user_data
  user_data = templatefile("${path.module}/user-data/frontend.sh.tftpl", {
    s3_log_bucket = aws_s3_bucket.app_logs.bucket
  })

  user_data_replace_on_change = true

  # ✅ EXPLICIT DEPENDENCY (for practice - Terraform auto-detects this anyway)
  depends_on = [
    aws_s3_bucket.app_logs,
    aws_iam_instance_profile.ec2_logs
  ]

  tags = {
    Name = "infrawave-frontend"
  }
}