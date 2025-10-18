# Setup CloudFront OAC
resource "aws_cloudfront_origin_access_control" "QuizAC" {
  name                              = "QuizOAC${random_uuid.uuid.id}"
  description                       = "The OAC for the IT Quiz"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Setup CloudFront distribution with S3 & API GW Origin
locals {
  s3_origin_id  = "myS3Origin"
  api_origin_id = "myAPIOrigin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.QuizAC.id
    origin_id                = local.s3_origin_id
  }

  # Set up API GW origin
  origin {
    domain_name = "${aws_api_gateway_rest_api.quiz_api.id}.execute-api.${var.region}.amazonaws.com"
    origin_id   = local.api_origin_id


    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]

    }
  }


  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Welcome to the IT Quiz!"
  default_root_object = "index.html"
  retain_on_delete    = "true"

  # Create behavior for S3 origin

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

  # Create behavior for API GW Origin
  ordered_cache_behavior {
    path_pattern     = "/success/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.api_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "Quiz_Distribution"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}

