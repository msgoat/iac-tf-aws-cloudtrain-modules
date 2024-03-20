terraform {
  required_providers {
    aws    = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      version = "~> 3.0"
    }
  }
}

provider aws {
  region = var.region_name
}

resource "aws_cognito_user_pool" "pool" {
  name = "example_user_pool"
}

resource "aws_cognito_user_pool_client" "client" {
  name                = "example_external_api"
  user_pool_id        = aws_cognito_user_pool.pool.id
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "authorizer-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

module "authorizer" {
  source                = "../../../modules/serverless/lambda"
  common_tags           = var.common_tags
  description           = "Lambda Authorizer"
  handler               = "authorizer/authorizer.handler"
  name                  = "DemoLambdaApiGatewayAuthorizer"
  filename              = "${path.module}/authorizer.zip"
  region_name           = var.region_name
  runtime               = "nodejs18.x"
  solution_fqn          = var.solution_fqn
  solution_name         = var.solution_name
  solution_stage        = var.solution_stage
  environment_variables = {
    USER_POOL_ID        = aws_cognito_user_pool.pool.id
    USER_POOL_CLIENT_ID = aws_cognito_user_pool_client.client.id
  }
}

module "api-gateway" {
  source         = "../../../modules/serverless/api-gateway"
  region_name    = var.region_name
  solution_fqn   = var.solution_fqn
  solution_name  = var.solution_name
  solution_stage = var.solution_stage
  common_tags    = var.common_tags
  name           = "example-api-gateway"
  stage          = "test"

  authorizer = {
    name              = "CustomAuthorizer"
    type              = "TOKEN"
    authorization     = "CUSTOM"
    lambda_invoke_arn = module.authorizer.invoke_arn
    lambda_arn        = module.authorizer.arn
  }

  paths = [
    {
      method      = "GET"
      path        = "/api/v1/example"
      type        = "AWS_PROXY"
      public      = true
      destination = module.lambda.invoke_arn
    },
    {
      method      = "POST"
      path        = "/api/v1/example"
      type        = "AWS_PROXY"
      destination = module.lambda.invoke_arn
    },
    {
      method      = "GET"
      path        = "/api/v2/example"
      type        = "AWS_PROXY"
      public      = true
      destination = module.lambda.invoke_arn
    },
    {
      method      = "POST"
      path        = "/api/v2/example"
      type        = "AWS_PROXY"
      destination = module.lambda.invoke_arn
    },
    {
      method      = "PUT"
      path        = "/api/v2/example"
      type        = "AWS_PROXY"
      destination = module.lambda.invoke_arn
    }
  ]
}