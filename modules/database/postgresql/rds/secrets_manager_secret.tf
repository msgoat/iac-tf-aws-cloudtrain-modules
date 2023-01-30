# create a SecretsManager secret to hold postgres username and password
resource aws_secretsmanager_secret postgres {
  name = local.db_instance_name
  kms_key_id = aws_kms_key.cmk.arn
  tags = merge({ Name = local.db_instance_name }, local.module_common_tags)
}

locals {
  secret_value = {
    postgresql-user = aws_db_instance.postgresql.username
    postgresql-password = aws_db_instance.postgresql.password
  }
}

# attach the JSON encoded secrets values to the SecretsManager secret
resource aws_secretsmanager_secret_version postgres {
  secret_id = aws_secretsmanager_secret.postgres.id
  secret_string = jsonencode(local.secret_value)
}