terraform {
  required_providers {
    aws = {
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

resource "aws_api_gateway_rest_api" "example" {
  body = jsonencode({
    openapi = "3.0.1"
    info    = {
      title   = "example"
      version = "1.0"
    }
    paths = {
      "/api/v1/example" = {}
    }
  })

  name = "example"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

module "lambda" {
  source         = "../../../../modules/serverless/lambda"
  common_tags    = var.common_tags
  description    = "Test Lambda with Rest API event source"
  handler        = "lambda_function.handler"
  name           = "DemoLambdaApiGateway"
  filename       = "${path.module}/lambda_function.mjs"
  region_name    = var.region_name
  runtime        = "nodejs18.x"
  solution_fqn   = var.solution_fqn
  solution_name  = var.solution_name
  solution_stage = var.solution_stage
  event_source   = "api"
  events         = {
    sqs = null
    sns = null
    api = {
      id     = aws_api_gateway_rest_api.example.id
      name   = aws_api_gateway_rest_api.example.name
      method = "GET"
      path   = "/api/v1/example"
    }
    schedule = null
  }
  depends_on = [aws_api_gateway_rest_api.example]
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = "test"

  depends_on = [module.lambda]
}