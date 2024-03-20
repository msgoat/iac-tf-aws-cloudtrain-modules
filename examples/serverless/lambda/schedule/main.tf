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

module "lambda" {
  source         = "../../../../modules/serverless/lambda"
  common_tags    = var.common_tags
  description    = "Test Lambda with Schedule event source"
  handler        = "lambda_function.handler"
  name           = "DemoLambdaSchedule"
  filename       = "${path.module}/lambda_function.mjs"
  region_name    = var.region_name
  runtime        = "nodejs18.x"
  solution_fqn   = var.solution_fqn
  solution_name  = var.solution_name
  solution_stage = var.solution_stage
  event_source   = "schedule"
  events         = {
    sqs      = null
    sns      = null
    api      = null
    schedule = {
      expression          = "cron(0 9 ? * * *)"
      expression_timezone = "Europe/Berlin"
    }
  }
}