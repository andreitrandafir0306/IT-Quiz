# Creation of local JS file to store the API Gateway as ENV var

resource "local_file" "frontend_config" {
  content  = "API_URL = \"https://${aws_api_gateway_rest_api.quiz_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.quiz_api_stage.stage_name}/${aws_api_gateway_resource.submit.path_part}\";"
  filename = "../config.js"
  depends_on = [aws_api_gateway_deployment.quiz_api_deploy]
}