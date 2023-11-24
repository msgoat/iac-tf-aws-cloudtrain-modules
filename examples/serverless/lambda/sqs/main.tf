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

resource "aws_sqs_queue" "example" {
  name = "lambda-demo-queue"
  tags = var.common_tags
}

module "lambda" {
  source         = "../../../../modules/serverless/lambda"
  common_tags    = var.common_tags
  description    = "Test Lambda with SQS event source"
  handler        = "lambda_function.handler"
  name           = "DemoLambdaSQSQueue"
  filename       = "${path.module}/lambda_function.mjs"
  region_name    = var.region_name
  runtime        = "nodejs18.x"
  solution_fqn   = var.solution_fqn
  solution_name  = var.solution_name
  solution_stage = var.solution_stage
  event_source   = "sqs"
  events         = {
    sqs = aws_sqs_queue.example.arn
    sns = null
    api = null
  }
  depends_on     = [aws_sqs_queue.example]
}