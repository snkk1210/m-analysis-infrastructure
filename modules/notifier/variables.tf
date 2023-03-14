variable "notifier_groups" {
  type = list(object({
    name        = string
    bucket_name = string
    prefix      = string
    lambda_arn  = string
  }))
}