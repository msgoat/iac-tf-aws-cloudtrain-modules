locals {
  unique_paths = toset([for path in var.paths : path.path])
}

resource "aws_api_gateway_rest_api" "this" {
  body = jsonencode({
    openapi = "3.0.1"
    info    = {
      title   = var.name
      version = "1.0"
    }
    paths   = {
    for path in local.unique_paths : path => {}
    }
  })

  name = var.name

  endpoint_configuration {
    types = [var.type]
  }
}

data "aws_api_gateway_resource" "resource" {
  count       = length(var.paths)
  rest_api_id = aws_api_gateway_rest_api.this.id
  path        = var.paths[count.index].path
}

resource "aws_api_gateway_method" "method" {
  count         = length(var.paths)
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = data.aws_api_gateway_resource.resource[count.index].id
  http_method   = var.paths[count.index].method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  count                   = length(var.paths)
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = data.aws_api_gateway_resource.resource[count.index].id
  http_method             = aws_api_gateway_method.method[count.index].http_method
  integration_http_method = var.paths[count.index].type == "AWS_PROXY" ? "POST" : var.paths[count.index].method
  type                    = var.paths[count.index].type
  uri                     = var.paths[count.index].destination
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.stage
  depends_on  = [aws_api_gateway_integration.integration]
}