resource "aws_lambda_event_source_mapping" "sqs_event_source_zip" {
  count            = var.event_source == "sqs" && var.filename != null ? 1 : 0
  event_source_arn = var.events.sqs
  function_name    = aws_lambda_function.zip[0].arn
}

resource "aws_lambda_event_source_mapping" "sqs_event_source_s3" {
  count            = var.event_source == "sqs" && var.s3_bucket != null ? 1 : 0
  event_source_arn = var.events.sqs
  function_name    = aws_lambda_function.s3[0].arn
}

resource "aws_lambda_event_source_mapping" "sqs_event_source_image" {
  count            = var.event_source == "sqs" && var.image_uri != null ? 1 : 0
  event_source_arn = var.events.sqs
  function_name    = aws_lambda_function.image[0].arn
}