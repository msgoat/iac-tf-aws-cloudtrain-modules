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

resource "aws_api_gateway_authorizer" "this" {
  count                  = var.authorizer.authorization != "NONE" ? 1 : 0
  name                   = var.authorizer.name
  type                   = var.authorizer.type
  rest_api_id            = aws_api_gateway_rest_api.this.id
  provider_arns          = var.authorizer.authorization == "COGNITO_USER_POOLS" ? [var.authorizer.user_pool_arn] : null
  authorizer_uri         = var.authorizer.authorization == "CUSTOM" ? var.authorizer.lambda_invoke_arn : null
  authorizer_credentials = var.authorizer.authorization == "CUSTOM" ? aws_iam_role.invocation_role[0].arn : null
}

data "aws_iam_policy_document" "invocation_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "invocation_policy" {
  count = var.authorizer.authorization == "CUSTOM" ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [var.authorizer.lambda_arn]
  }
}

resource "aws_iam_role_policy" "invocation_policy" {
  count  = var.authorizer.authorization == "CUSTOM" ? 1 : 0
  name   = "default"
  role   = aws_iam_role.invocation_role[0].id
  policy = data.aws_iam_policy_document.invocation_policy[0].json
}

resource "aws_iam_role" "invocation_role" {
  count              = var.authorizer.authorization == "CUSTOM" ? 1 : 0
  name               = "${var.name}_authorizer_invocation"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role.json
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
  authorization = var.paths[count.index].public ? "NONE" : var.authorizer.authorization
  authorizer_id = var.paths[count.index].public || var.authorizer.authorization == "NONE" ? null : aws_api_gateway_authorizer.this[0].id
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