resource "aws_dynamodb_table" "backend" {
  name     = local.dynamodb_table_name
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
  server_side_encryption {
    enabled = true
  }
  tags = merge({ Name = local.dynamodb_table_name }, local.module_common_tags)
}
