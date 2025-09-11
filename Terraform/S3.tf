# Create S3 bucket 

resource "aws_s3_bucket" "website" {
  bucket = "my-it-quiz-123"

  tags = {
    Name        = "Simple IT Quiz"
  }
}

# Add index.html, index.css & index.js in the bucket

resource "aws_s3_object" "html" {
  bucket = aws_s3_bucket.website.bucket
  key    = "index.html"
  source = "../index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "css" {
  bucket = aws_s3_bucket.website.bucket
  key    = "index.css"
  source = "../index.css"
  content_type = "text/css"
}

resource "aws_s3_object" "js" {
  bucket = aws_s3_bucket.website.bucket
  key    = "index.js"
  source = "../index.js"
  content_type = "application/javascript"
  
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
            "AWS:SourceArn" = "aws_cloudfront_distribution.s3_distribution.arn"
          }
        }
      }
    ]
  })
}