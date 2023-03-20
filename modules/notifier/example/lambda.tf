// AWS アカウント Region 参照
data "aws_region" "self" {}

data "archive_file" "example" {
  type        = "zip"
  source_file = "${path.module}/lambda/source/example.py"
  output_path = "${path.module}/lambda/bin/example.zip"
}

resource "aws_lambda_function" "example" {
  filename                       = data.archive_file.example.output_path
  function_name                  = "${var.project}-${var.environment}-example-notifier-function"
  description                    = "${var.project}-${var.environment}-example-notifier-function"
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "example.lambda_handler"
  source_code_hash               = data.archive_file.example.output_base64sha256
  reserved_concurrent_executions = var.reserved_concurrent_executions
  runtime                        = "python3.9"

  environment {
    variables = {
      //
    }
  }

  lifecycle {
    ignore_changes = [
      //environment
    ]
  }

}

/**
# NOTE: IAM Role For example Alarm Lambda
*/

// Lambda role
resource "aws_iam_role" "lambda_role" {
  name               = "${var.project}-${var.environment}-${data.aws_region.self.name}-example-notifier-lambda-role"
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
  name = "${var.project}-${var.environment}-${data.aws_region.self.name}-example-notifier-lambda-policy"
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
resource "aws_kms_key" "example_lambda" {
  description             = "${var.project}-${var.environment}-example-notifier-lambda-kms"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  is_enabled              = true
}

// 環境変数暗号化 KMS Alias
resource "aws_kms_alias" "example_lambda" {
  name          = "alias/${var.project}/${var.environment}/example_notifier_lambda_kms_key"
  target_key_id = aws_kms_key.example_lambda.id
}
*/