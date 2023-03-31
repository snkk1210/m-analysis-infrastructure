resource "aws_cloudfront_origin_request_policy" "request_policy" {
  name    = "${var.project}-${var.environment}-cf2s3-request-policy"
  comment = "${var.project}-${var.environment}-cf2s3-request-policy"

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

}