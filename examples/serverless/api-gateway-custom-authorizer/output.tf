output "url" {
  value       = module.api-gateway.url
  description = "API Gateway execution url"
}

output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.client.id
}