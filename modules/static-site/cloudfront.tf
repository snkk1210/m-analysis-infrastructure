/** 
# NOTE: CloudFront
*/
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "An access identity for ${var.project} ${var.environment} orgin s3 bucket"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  comment             = "${var.project}-${var.environment}-cf-distribution"
  aliases             = [var.domain_name]
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.log.bucket_domain_name
    prefix          = var.log_prefix
  }

  origin {
    domain_name = aws_s3_bucket.origin.bucket_domain_name
    origin_id   = "${var.project}-${var.environment}-s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  // Default Cache Behavior
  default_cache_behavior {
    target_origin_id = "${var.project}-${var.environment}-s3-origin"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]
    cached_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]

    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id          = aws_cloudfront_cache_policy.cache_policy.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.request_policy.id

    // CloudFront Functions ( Basic Auth )
    dynamic function_association {
      for_each = var.enable_basic_auth ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.basic_auth.arn
      }
    }
  }

  // Custom Error Response
  dynamic "custom_error_response" {
    for_each = var.custom_error_response_rules
    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  tags = {
    Name        = "${var.project}-${var.environment}-cf-distribution"
    Environment = var.environment
  }
}