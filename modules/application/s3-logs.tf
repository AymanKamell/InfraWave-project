# modules/application/s3-logs.tf

# Generate unique suffix to avoid global naming conflicts
resource "random_id" "bucket_suffix" {
  byte_length = 4  # Creates 8-char hex suffix (e.g., "a3f9b2c1")
}

# Main log bucket
resource "aws_s3_bucket" "app_logs" {
  bucket = "infrawave-app-logs-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "infrawave-app-logs"
    Project     = "InfraWave"
    Environment = "Production"
    # Cost allocation tags for AWS Cost Explorer
    CostCenter  = "devops"
  }
}

# 🔒 CRITICAL: Block ALL public access (non-negotiable)
resource "aws_s3_bucket_public_access_block" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  block_public_acls       = true  # Block new public ACLs
  block_public_policy     = true  # Block bucket policies granting public access
  ignore_public_acls      = true  # Ignore existing public ACLs
  restrict_public_buckets = true  # Block public access even if ACLs exist
}

# 🔒 Encrypt all data at rest (AES-256 = free, no KMS key management needed)
resource "aws_s3_bucket_server_side_encryption_configuration" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Simpler than KMS for logs
    }
  }
}

# 🛡️ Enable versioning for accidental deletion protection
resource "aws_s3_bucket_versioning" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 💰 Cost optimization: Auto-tier old logs to cheaper storage
resource "aws_s3_bucket_lifecycle_configuration" "app_logs" {
  bucket = aws_s3_bucket.app_logs.id

  rule {
    id = "log-retention-policy"

    # Delete logs after 365 days (compliance-friendly)
    expiration {
      days = 365
    }

    # Move to cheaper storage after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"  # 40% cheaper than standard
    }

    # Archive to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"      # 90% cheaper
    }

    status = "Enabled"
  }
}