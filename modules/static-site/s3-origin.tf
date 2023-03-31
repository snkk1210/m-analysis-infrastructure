/** 
# NOTE: Origin S3 Bucket
*/

// S3 操作 ポリシー
data "aws_iam_policy_document" "cf_to_s3" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.origin.arn}",
      "${aws_s3_bucket.origin.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

// Origin S3 
resource "aws_s3_bucket" "origin" {
  bucket = "${var.project}-${var.environment}-origin-bucket"

  tags = {
    Name        = "${var.project}-${var.environment}-origin-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "origin" {
  bucket = aws_s3_bucket.origin.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "origin" {
  bucket = aws_s3_bucket.origin.id
  acl    = "private"
}

// S3 パブリックアクセス設定
resource "aws_s3_bucket_public_access_block" "origin" {
  bucket = aws_s3_bucket.origin.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// S3 暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "origin" {
  bucket = aws_s3_bucket.origin.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// CloudFront 許可 ポリシー 付与
resource "aws_s3_bucket_policy" "cf_to_s3" {
  bucket = aws_s3_bucket.origin.id
  policy = data.aws_iam_policy_document.cf_to_s3.json
}