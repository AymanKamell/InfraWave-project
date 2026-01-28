# modules/application/outputs.tf

output "frontend_public_ip" {
  description = "Public IP of frontend EC2"
  value       = aws_instance.frontend-ec2.public_ip
}

output "backend_private_ip" {
  description = "Private IP of backend EC2"
  value       = aws_instance.backend-ec2.private_ip
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.app.endpoint
}

output "log_bucket_name" {
  description = "S3 bucket name for application logs"
  value       = aws_s3_bucket.app_logs.bucket
}

output "backend_api_url" {
  description = "Backend API health check URL"
  value       = "http://${aws_instance.backend-ec2.private_ip}:${var.app_port}/api/health"
}