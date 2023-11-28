data "aws_api_gateway_rest_api" "rest-api" {
  count = var.event_source == "api" ? 1 : 0
  name  = var.events.api.name
}

data "aws_api_gateway_resource" "resource" {
  count       = var.event_source == "api" ? 1 : 0
  rest_api_id = var.events.api.id
  path        = var.events.api.path
}

resource "aws_api_gateway_method" "method" {
  count         = var.event_source == "api" ? 1 : 0
  rest_api_id   = var.events.api.id
  resource_id   = data.aws_api_gateway_resource.resource[0].id
  http_method   = var.events.api.method
  authorization = "NONE"
}

#### ZIP integration
resource "aws_api_gateway_integration" "example_integration_zip" {
  count                   = var.event_source == "api" && var.filename != null ? 1 : 0
  rest_api_id             = var.events.api.id
  resource_id             = data.aws_api_gateway_resource.resource[0].id
  http_method             = aws_api_gateway_method.method[0].http_method
  integration_http_method = "POST" # must be POST for Lambda integration
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.zip[0].invoke_arn
}

resource "aws_lambda_permission" "zip" {
  count         = var.event_source == "api" && var.filename != null ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.zip[0].function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${data.aws_api_gateway_rest_api.rest-api[0].execution_arn}/*/*"
}

#### S3 integration
resource "aws_api_gateway_integration" "example_integration_s3" {
  count                   = var.event_source == "api" && var.s3_bucket != null ? 1 : 0
  rest_api_id             = var.events.api.id
  resource_id             = data.aws_api_gateway_resource.resource[0].id
  http_method             = aws_api_gateway_method.method[0].http_method
  integration_http_method = "POST" # must be POST for Lambda integration
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.s3[0].invoke_arn
}

resource "aws_lambda_permission" "s3" {
  count         = var.event_source == "api" && var.s3_bucket != null ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3[0].function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${data.aws_api_gateway_rest_api.rest-api[0].execution_arn}/*/*"
}

#### Image integration
resource "aws_api_gateway_integration" "example_integration_image" {
  count                   = var.event_source == "api" && var.image_uri != null ? 1 : 0
  rest_api_id             = var.events.api.id
  resource_id             = data.aws_api_gateway_resource.resource[0].id
  http_method             = aws_api_gateway_method.method[0].http_method
  integration_http_method = "POST" # must be POST for Lambda integration
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.image[0].invoke_arn
}

resource "aws_lambda_permission" "image" {
  count         = var.event_source == "api" && var.image_uri != null ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image[0].function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${data.aws_api_gateway_rest_api.rest-api[0].execution_arn}/*/*"
}

