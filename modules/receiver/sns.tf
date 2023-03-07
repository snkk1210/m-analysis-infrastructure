resource "aws_sns_topic" "receiver" {
  name         = "${var.project}-${var.environment}-ses-receiver-sns-topic"
  display_name = "${var.project}-${var.environment}-ses-receiver-sns-topic"
}

resource "aws_sns_topic_subscription" "receiver" {
  topic_arn = aws_sns_topic.receiver.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.receiver.arn
}