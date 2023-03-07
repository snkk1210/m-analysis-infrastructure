resource "aws_ses_receipt_rule_set" "receiver" {
  rule_set_name = "${var.project}-${var.environment}-ses-rule-set"
}

resource "aws_ses_receipt_rule" "receiver" {
  name = "${var.project}-${var.environment}-ses-rule"
  rule_set_name = aws_ses_receipt_rule_set.receiver.rule_set_name
  recipients = ["${var.receiver_domain}"]
  enabled = true
  scan_enabled = true

  sns_action {
    topic_arn = aws_sns_topic.receiver.arn
    position = 1
    encoding = "Base64"
  }
}

resource "aws_ses_active_receipt_rule_set" "receiver" {
  rule_set_name = aws_ses_receipt_rule_set.receiver.rule_set_name
}