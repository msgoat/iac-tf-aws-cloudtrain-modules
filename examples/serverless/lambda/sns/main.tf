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

resource "aws_sns_topic" "example" {
  name = "lambda-demo-topic"
}

module "lambda" {
  source         = "../../../../modules/serverless/lambda"
  common_tags    = var.common_tags
  description    = "Test Lambda with SNS event source"
  handler        = "lambda_function.handler"
  name           = "DemoLambdaSNSTopic"
  filename       = "${path.module}/lambda_function.mjs"
  region_name    = var.region_name
  runtime        = "nodejs18.x"
  solution_fqn   = var.solution_fqn
  solution_name  = var.solution_name
  solution_stage = var.solution_stage
  event_source   = "sns"
  events         = {
    sqs = null
    sns = aws_sns_topic.example.arn
    api = null
  }
  depends_on     = [aws_sns_topic.example]
}