/** 
# NOTE: S3-processed
*/

// S3
resource "aws_s3_bucket" "processed" {
  bucket = "${var.project}-${var.environment}-processed-bucket"

  tags = {
    Name        = "${var.project}-${var.environment}-processed-bucket"
    Environment = var.environment
  }
}

// S3 パブリックアクセス設定
resource "aws_s3_bucket_public_access_block" "processed" {
  bucket = aws_s3_bucket.processed.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// S3 暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "processed" {
  bucket = aws_s3_bucket.processed.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// EventBridge 通知
resource "aws_s3_bucket_notification" "processed" {
  bucket      = aws_s3_bucket.processed.id
  eventbridge = true
}