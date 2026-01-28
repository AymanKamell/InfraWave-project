# modules/application/iam.tf

# Simple IAM role for EC2 → S3 access
resource "aws_iam_role" "ec2_logs" {
  name = "infrawave-ec2-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Minimal policy: ONLY PutObject permission (least privilege)
resource "aws_iam_role_policy" "s3_logs" {
  name = "s3-put-object-only"
  role = aws_iam_role.ec2_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:PutObject"]
      Resource = "${aws_s3_bucket.app_logs.arn}/*"
    }]
  })
}

# Instance profile (required bridge for EC2)
resource "aws_iam_instance_profile" "ec2_logs" {
  name = "infrawave-ec2-logs-profile"
  role = aws_iam_role.ec2_logs.name
}