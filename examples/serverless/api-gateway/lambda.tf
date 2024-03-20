module "lambda" {
  source         = "../../../modules/serverless/lambda"
  common_tags    = var.common_tags
  description    = "Test Lambda"
  handler        = "lambda_function.handler"
  name           = "DemoLambdaApiGateway"
  filename       = "${path.module}/lambda_function.mjs"
  archive        = true
  region_name    = var.region_name
  runtime        = "nodejs18.x"
  solution_fqn   = var.solution_fqn
  solution_name  = var.solution_name
  solution_stage = var.solution_stage
}

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "DemoLambdaApiGateway"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${module.api-gateway.execution_arn}/*/*"
}