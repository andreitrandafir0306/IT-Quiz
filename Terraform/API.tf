# Create REST API

resource "aws_api_gateway_rest_api" "quiz_api" {
  name        = "quiz-api"
  description = "API for submitting quiz results"
}

# Create API Resource submit in order to send the results to Lambda via the REST API

resource "aws_api_gateway_resource" "submit" {
  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  parent_id   = aws_api_gateway_rest_api.quiz_api.root_resource_id
  path_part   = "submit"
}

# Create OPTIONS method with MOCK integration to bypass browser-based CORS

  resource "aws_api_gateway_method" "submit_options" {
  rest_api_id   = aws_api_gateway_rest_api.quiz_api.id
  resource_id   = aws_api_gateway_resource.submit.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Create OPTIONS method response

resource "aws_api_gateway_method_response" "method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.submit_options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Create MOCK integration

resource "aws_api_gateway_integration" "submit_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.submit_options.http_method
  type        = "MOCK"
}

# Create MOCK integration response 

resource "aws_api_gateway_integration_response" "quiz_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.submit_options.http_method
  status_code = aws_api_gateway_method_response.method_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin" = "'${aws_cloudfront_distribution.s3_distribution.domain_name}'"

  }
}

# Create POST to Lambda
resource "aws_api_gateway_method" "submit_post" {
  rest_api_id   = aws_api_gateway_rest_api.quiz_api.id
  resource_id   = aws_api_gateway_resource.submit.id
  http_method   = "POST"
  authorization = "NONE"
}

#Connect API GW with Lambda

resource "aws_api_gateway_integration" "submit_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.submit_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.submit_results.invoke_arn
}

#Allow API GW to invoke Lambda

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.submit_results.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.quiz_api.execution_arn}/*/*"
}

# Deploy & Stage the API and enable logging + permission to write to CloudWatch 

resource "aws_api_gateway_deployment" "quiz_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.quiz_api.id
  depends_on  = [aws_api_gateway_integration.submit_post_integration]
}

resource "aws_api_gateway_stage" "quiz_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.quiz_api.id
  deployment_id = aws_api_gateway_deployment.quiz_api_deploy.id
  stage_name    = "success"
}