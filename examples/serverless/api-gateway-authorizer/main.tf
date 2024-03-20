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
    name          = "UserPoolAuthorizer"
    type          = "COGNITO_USER_POOLS"
    authorization = "COGNITO_USER_POOLS"
    user_pool_arn = aws_cognito_user_pool.pool.arn
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