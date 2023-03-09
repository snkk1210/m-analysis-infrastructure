variable "project" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "receiver_domain" {
  type    = string
  default = ""
}

variable "reserved_concurrent_executions" {
  type = number
}