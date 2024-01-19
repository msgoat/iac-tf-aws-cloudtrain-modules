output "id" {
  value       = aws_api_gateway_rest_api.this.id
  description = "Id of the api gateway"
}

output "execution_arn" {
  value       = aws_api_gateway_rest_api.this.execution_arn
  description = "Execution arn of the api gateway"
}

output "url" {
  value       = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region_name}.amazonaws.com/${var.stage}"
  description = "API Gateway execution url"
}