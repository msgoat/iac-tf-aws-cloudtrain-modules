#### ZIP Lambda
resource "aws_sns_topic_subscription" "sns_subscription_zip" {
  count     = var.event_source == "sns" && var.filename != null ? 1 : 0
  topic_arn = var.events.sns
  protocol  = "lambda"
  endpoint  = aws_lambda_function.zip[0].arn
}

resource "aws_lambda_permission" "with_sns_zip" {
  count         = var.event_source == "sns" && var.filename != null ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.zip[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.events.sns
}

#### S3 Lambda
resource "aws_sns_topic_subscription" "sns_subscription_s3" {
  count     = var.event_source == "sns" && var.s3_bucket != null ? 1 : 0
  topic_arn = var.events.sns
  protocol  = "lambda"
  endpoint  = aws_lambda_function.s3[0].arn
}

resource "aws_lambda_permission" "with_sns_s3" {
  count         = var.event_source == "sns" && var.s3_bucket != null ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.events.sns
}

#### Container Image Lambda
resource "aws_sns_topic_subscription" "sns_subscription_image" {
  count     = var.event_source == "sns" && var.image_uri != null ? 1 : 0
  topic_arn = var.events.sns
  protocol  = "lambda"
  endpoint  = aws_lambda_function.image[0].arn
}

resource "aws_lambda_permission" "with_sns_image" {
  count         = var.event_source == "sns" && var.image_uri != null ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.events.sns
}