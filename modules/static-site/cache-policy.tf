resource "aws_cloudfront_cache_policy" "cache_policy" {
  name    = "${var.project}-${var.environment}-cf2s3-cache-policy"
  comment = "${var.project}-${var.environment}-cf2s3-cache-policy"

  default_ttl = var.default_ttl
  max_ttl     = var.max_ttl
  min_ttl     = var.min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {

    cookies_config {
      cookie_behavior = "none"
      cookies {
        items = []
      }
    }

    headers_config {
      header_behavior = "none"
      headers {
        items = []
      }
    }

    query_strings_config {
      query_string_behavior = "none"
      query_strings {
        items = []
      }
    }

    enable_accept_encoding_brotli = var.enable_accept_encoding_brotli
    enable_accept_encoding_gzip   = var.enable_accept_encoding_gzip

  }
}