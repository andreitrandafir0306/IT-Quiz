# Provision Lambda function

resource "aws_lambda_function" "submit_results" {
  function_name = "submit_results_lambda"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.13"
  handler       = "function.handler"

  filename = "function.zip" # zip Python code

  environment {
    variables = {
      TABLE_NAME        = aws_dynamodb_table.quiz_results.name
      DISTRIBUTION_NAME = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
    }
  }
}

# Execute Lambda with IAM Role to allow putting items in DynamoDB, reading CloudFront distribution & CloudWatch logging

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:PutItem"]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.quiz_results.arn
      },
      {
        Action   = ["cloudfront:GetDistribution", "cloudfront:ListDistributions"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
