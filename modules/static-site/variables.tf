/**
# NOTE: Variables
*/
variable "project" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

/**
# NOTE: ClooudFront Variables
*/
variable "domain_name" {
  type    = string
  default = ""
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "log_prefix" {
  type    = string
  default = ""
}

variable "custom_error_response_rules" {
  type = list(object({
    error_caching_min_ttl = number
    error_code            = number
    response_code         = number
    response_page_path    = string
    })
  )
}

variable "enable_basic_auth" {
  type    = bool
}

/**
# NOTE: ClooudFront Cache Policy Variables
*/
variable "default_ttl" {
  type    = string
  default = ""
}

variable "max_ttl" {
  type    = string
  default = ""
}

variable "min_ttl" {
  type    = string
  default = ""
}

variable "enable_accept_encoding_brotli" {
  type    = bool
  default = false
}

variable "enable_accept_encoding_gzip" {
  type    = bool
  default = false
}

/**
# NOTE: ClooudFront Log Variables
*/
variable "cf_log_lifecycle_days_to_glacier" {
  type    = number
}

variable "cf_log_lifecycle_days_to_expiration" {
  type    = number
}

/**
# NOTE: ClooudFront Function Variables
*/
variable "auth_user" {
  type    = string
  default = ""
}

variable "auth_pass" {
  type    = string
  default = ""
}