// AWS アカウント ID 参照
data "aws_caller_identity" "current_identity" {}

// S3 ポリシー
data "aws_iam_policy_document" "receiver" {

  // SES → S3 ポリシー
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${var.project}-${var.environment}-receiver-bucket/*"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ses.amazonaws.com"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:ses:*"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [
        "${data.aws_caller_identity.current_identity.account_id}"
      ]
    }
  }

}

/** 
# NOTE: S3-receiver
*/

// S3
resource "aws_s3_bucket" "receiver" {
  bucket = "${var.project}-${var.environment}-receiver-bucket"

  tags = {
    Name        = "${var.project}-${var.environment}-receiver-bucket"
    Environment = var.environment
  }
}

// ALB S3 ポリシー アタッチ
resource "aws_s3_bucket_policy" "receiver" {
  bucket = aws_s3_bucket.receiver.id
  policy = data.aws_iam_policy_document.receiver.json
}

// S3 パブリックアクセス設定
resource "aws_s3_bucket_public_access_block" "receiver" {
  bucket = aws_s3_bucket.receiver.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}

// S3 暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "receiver" {
  bucket = aws_s3_bucket.receiver.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}