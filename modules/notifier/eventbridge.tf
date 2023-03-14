resource "aws_cloudwatch_event_rule" "notifier" {
  for_each = { for notifier_group in var.notifier_groups : notifier_group.name => notifier_group }

  name        = "${var.project}-${var.environment}-${each.value.name}-event-rule"
  description = "${var.project}-${var.environment}-${each.value.name}-event-rule"

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": [${each.value.bucket}]
    },
    "object": {
      "key": [{
        "prefix": "${each.value.prefix}"
      }]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "notifier" {
  for_each = { for notifier_group in var.notifier_groups : notifier_group.name => notifier_group }

  rule      = aws_cloudwatch_event_rule.notifier[each.value.name].name
  target_id = "${var.common.project}-${var.common.environment}-${each.value.name}-target"
  arn       = each.value.lambda_arn
}
