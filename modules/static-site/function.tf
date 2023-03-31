data "template_file" "basic_auth" {
  template = file("${path.module}/files/basic-auth.js")

  vars = {
    auth_user = var.auth_user
    auth_pass = var.auth_pass
  }
}

resource "aws_cloudfront_function" "basic_auth" {
  name    = "${var.project}-${var.environment}-basic-auth-function"
  runtime = "cloudfront-js-1.0"
  comment = "${var.project}-${var.environment}-basic-auth-function"
  publish = true
  code    = data.template_file.basic_auth.rendered
}