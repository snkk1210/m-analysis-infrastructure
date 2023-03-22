variable "project" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "hookurl" {
  type = string
}

variable "channel_name" {
  type = string
}

variable "lambda_timezone" {
  type    = string
  default = "Asia/Tokyo"
}

variable "reserved_concurrent_executions" {
  type = number
}