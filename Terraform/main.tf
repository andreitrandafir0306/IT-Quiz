# Create S3 bucket 

resource "aws_s3_bucket" "website" {
  bucket = "my-it-quiz-123"

  tags = {
    Name        = "Simple IT Quiz"
  }
}

# Public access block

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Setup bucket ACL & object ownership 

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "website" {
  depends_on = [aws_s3_bucket_ownership_controls.website]

  bucket = aws_s3_bucket.website.id
  acl    = "private"
}

#Setup CloudFront OAC 

resource "aws_cloudfront_origin_access_control" "QuizOAC" {
  name                              = "QuizOAC"
  description                       = "The OAC for the IT Quiz"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#Setup CloudFront distribution

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.QuizOAC.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Welcome to the IT Quiz!"
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

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

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
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

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["RO", "FR", "GB", "DE"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


#Setup bucket policy for OAC

resource "aws_s3_bucket_policy" "quiz_policy" {
  bucket = aws_s3_bucket.website.id

 policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::911167916458:distribution/EBO458VZ9F37M"
          }
        }
      }
    ]
  })
}

#Setup Cognito User Pool & UI

resource "aws_cognito_user_pool" "quiz_pool" {
  name = "quiz-user-pool"

  # MFA & Security
  mfa_configuration = "ON"   # Enforces MFA for all users
  software_token_mfa_configuration {
    enabled = true          # TOTP MFA (Google Authenticator)
  }

  # Password policy
  password_policy {
    minimum_length    = 10
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  # Email verification
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "quiz_client" {
  name         = "quiz-app-client"
  user_pool_id = aws_cognito_user_pool.quiz_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"

# Hosted UI redirect
  callback_urls = ["https://d2vb6rqa0f3y75.cloudfront.net"]
  logout_urls   = ["https://d2vb6rqa0f3y75.cloudfront.net"]
}