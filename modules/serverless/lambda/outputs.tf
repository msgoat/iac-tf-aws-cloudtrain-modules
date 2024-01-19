output "invoke_arn" {
  value       = var.s3_bucket != null ? aws_lambda_function.s3[0].invoke_arn : var.image_uri != null ? aws_lambda_function.image[0].invoke_arn : aws_lambda_function.zip[0].invoke_arn
  description = "Invocation arn of the lambda function."
}