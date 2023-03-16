variable "project" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "notifier_groups" {
  type = list(object({
    name                 = string
    bucket_name          = string
    prefix               = string
    lambda_arn           = string
    lambda_function_name = string
  }))
}