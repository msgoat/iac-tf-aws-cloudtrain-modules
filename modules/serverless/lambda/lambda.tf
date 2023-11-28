data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "sqs_role" {
  count      = var.event_source == "sqs" ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

data "archive_file" "lambda" {
  count       = var.filename != null ? 1 : 0
  type        = "zip"
  source_file = var.filename
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "zip" {
  count         = var.filename != null ? 1 : 0
  filename      = "lambda_function.zip"
  function_name = var.name
  description   = var.description
  role          = aws_iam_role.role.arn
  handler       = var.handler

  source_code_hash = data.archive_file.lambda[0].output_base64sha256

  package_type = "Zip"

  runtime       = var.runtime
  architectures = var.architectures
  memory_size   = var.memory_size

  environment {
    variables = var.environment_variables
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.log_group
  ]
}

resource "aws_lambda_function" "s3" {
  count         = var.s3_bucket != null ? 1 : 0
  function_name = var.name
  description   = var.description
  role          = aws_iam_role.role.arn
  handler       = var.handler
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key

  package_type = "Zip"

  runtime       = var.runtime
  architectures = var.architectures
  memory_size   = var.memory_size

  environment {
    variables = var.environment_variables
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.log_group
  ]
}

resource "aws_lambda_function" "image" {
  count         = var.image_uri != null ? 1 : 0
  function_name = var.name
  description   = var.description
  role          = aws_iam_role.role.arn
  handler       = var.handler

  image_uri = var.image_uri

  package_type = "Image"

  runtime       = var.runtime
  architectures = var.architectures
  memory_size   = var.memory_size

  environment {
    variables = var.environment_variables
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.log_group
  ]
}
