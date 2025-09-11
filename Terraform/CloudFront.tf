# Setup CloudFront OAC
resource "aws_cloudfront_origin_access_control" "QuizAC" {
  name                              = "QuizAC"
  description                       = "The OAC for the IT Quiz"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Setup CloudFront distribution with S3 & API GW Origin
locals {
  s3_origin_id = "myS3Origin"
  api_origin_id = "myAPIOrigin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.QuizAC.id
    origin_id                = local.s3_origin_id
  }

  origin {
    domain_name              = "${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com"
    origin_id                = local.api_origin_id
  }

  custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Welcome to the IT Quiz!"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
