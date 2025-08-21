# Provision DynamoDB table 

resource "aws_dynamodb_table" "quiz_results" {
  name           = "quiz_results"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  tags = {
    Name        = "Quiz Results"
    Environment = "dev"
    Project     = "quiz-app"
  }
}