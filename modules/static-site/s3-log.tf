/** 
# NOTE: Log S3 Bucket
*/

// AWS アカウント ID 参照
data "aws_caller_identity" "current_identity" {}

// ログ保管 S3
resource "aws_s3_bucket" "log" {
  bucket = "${var.project}-${var.environment}-cf-log-bucket"

  tags = {
    Name        = "${var.project}-${var.environment}-cf-log-bucket"
    Environment = var.environment
  }
}

// Log S3 バケット ライフサイクル設定
resource "aws_s3_bucket_lifecycle_configuration" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    id     = "CloudFront_Log_Expiration"
    status = "Enabled"

    dynamic transition {
      for_each = var.cf_log_lifecycle_days_to_glacier > 0 ? [1] : []
      content {
        days          = var.cf_log_lifecycle_days_to_glacier
        storage_class = "GLACIER"
      }
    }

    dynamic expiration {
      for_each = var.cf_log_lifecycle_days_to_expiration > 0 ? [1] : []
      content {
        days = var.cf_log_lifecycle_days_to_expiration
      }
    }
  }
}

// S3 パブリックアクセス設定
resource "aws_s3_bucket_public_access_block" "log" {
  bucket = aws_s3_bucket.log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// S3 暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}