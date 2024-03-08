#### ZIP Lambda
resource "aws_scheduler_schedule" "zip" {
  count = var.event_source == "schedule" && var.filename != null ? 1 : 0
  name       = "${var.name}-schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.events.schedule.expression
  schedule_expression_timezone = var.events.schedule.expression_timezone

  target {
    arn      = aws_lambda_function.zip[0].arn
    role_arn = aws_iam_role.scheduler_role_zip[0].arn
  }
}

resource "aws_iam_role" "scheduler_role_zip" {
  count = var.event_source == "schedule" && var.filename != null ? 1 : 0
  name = "EventBridgeSchedulerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_invoke_policy_zip" {
  count = var.event_source == "schedule" && var.filename != null ? 1 : 0
  name = "EventBridgeInvokeLambdaPolicy"
  role = aws_iam_role.scheduler_role_zip[0].id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowEventBridgeToInvokeLambda",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Effect" : "Allow",
        "Resource" : aws_lambda_function.zip[0].arn
      }
    ]
  })
}

#### Image Lambda
resource "aws_scheduler_schedule" "image" {
  count = var.event_source == "schedule" && var.image_uri != null ? 1 : 0
  name       = "${var.name}-schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.events.schedule.expression
  schedule_expression_timezone = var.events.schedule.expression_timezone

  target {
    arn      = aws_lambda_function.image[0].arn
    role_arn = aws_iam_role.scheduler_role_image[0].arn
  }
}

resource "aws_iam_role" "scheduler_role_image" {
  count = var.event_source == "schedule" && var.image_uri != null ? 1 : 0
  name = "EventBridgeSchedulerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_invoke_policy_image" {
  count = var.event_source == "schedule" && var.image_uri != null ? 1 : 0
  name = "EventBridgeInvokeLambdaPolicy"
  role = aws_iam_role.scheduler_role_image[0].id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowEventBridgeToInvokeLambda",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Effect" : "Allow",
        "Resource" : aws_lambda_function.image[0].arn
      }
    ]
  })
}

#### S3 Lambda
resource "aws_scheduler_schedule" "s3" {
  count = var.event_source == "schedule" && var.s3_bucket != null ? 1 : 0
  name       = "${var.name}-schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.events.schedule.expression
  schedule_expression_timezone = var.events.schedule.expression_timezone

  target {
    arn      = aws_lambda_function.s3[0].arn
    role_arn = aws_iam_role.scheduler_role_s3[0].arn
  }
}

resource "aws_iam_role" "scheduler_role_s3" {
  count = var.event_source == "schedule" && var.image_uri != null ? 1 : 0
  name = "EventBridgeSchedulerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_invoke_policy_s3" {
  count = var.event_source == "schedule" && var.image_uri != null ? 1 : 0
  name = "EventBridgeInvokeLambdaPolicy"
  role = aws_iam_role.scheduler_role_s3[0].id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowEventBridgeToInvokeLambda",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Effect" : "Allow",
        "Resource" : aws_lambda_function.s3[0].arn
      }
    ]
  })
}
