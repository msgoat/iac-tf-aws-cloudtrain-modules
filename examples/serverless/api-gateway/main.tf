terraform {
  required_providers {
    aws    = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      version = "~> 3.0"
    }
  }
}

provider aws {
  region = var.region_name
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

  paths = [
    {
      method      = "GET"
      path        = "/api/v1/example"
      type        = "AWS_PROXY"
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