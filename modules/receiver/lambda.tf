// AWS アカウント Region 参照
data "aws_region" "self" {}

data "archive_file" "receiver" {
  type        = "zip"
  source_file = "${path.module}/lambda/source/receiver.py"
  output_path = "${path.module}/lambda/bin/receiver.zip"
}

resource "aws_lambda_function" "receiver" {
  filename                       = data.archive_file.receiver.output_path
  function_name                  = "${var.project}-${var.environment}-receiver-function"
  description                    = "${var.project}-${var.environment}-receiver-function"
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "receiver.lambda_handler"
  source_code_hash               = data.archive_file.receiver.output_base64sha256
  reserved_concurrent_executions = var.reserved_concurrent_executions
  runtime                        = "python3.9"

  environment {
    variables = {
      s3BucketName = aws_s3_bucket.processed.id
    }
  }

  lifecycle {
    ignore_changes = [
      //environment
    ]
  }

}

resource "aws_lambda_permission" "receiver" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.receiver.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.receiver.arn
}

/**
# NOTE: IAM Role For receiver Alarm Lambda
*/

// Lambda role
resource "aws_iam_role" "lambda_role" {
  name               = "${var.project}-${var.environment}-${data.aws_region.self.name}-receiver-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// Lambda 基本実行 ポリシー アタッチ
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// S3 アクセス ポリシー アタッチ
resource "aws_iam_role_policy_attachment" "lambda_to_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

// SSM パラメータ 読み込み ポリシー
resource "aws_iam_policy" "lambda_to_ssm" {
  name = "${var.project}-${var.environment}-${data.aws_region.self.name}-receiver-lambda-policy"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

// SSM パラメータ 読み込み ポリシー アタッチ
resource "aws_iam_role_policy_attachment" "lambda_to_ssm" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_to_ssm.arn
}

/**
// 環境変数暗号化 KMS
resource "aws_kms_key" "receiver_lambda" {
  description             = "${var.project}-${var.environment}-receiver-lambda-kms"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  is_enabled              = true
}

// 環境変数暗号化 KMS Alias
resource "aws_kms_alias" "receiver_lambda" {
  name          = "alias/${var.project}/${var.environment}/receiver_lambda_kms_key"
  target_key_id = aws_kms_key.receiver_lambda.id
}
*/