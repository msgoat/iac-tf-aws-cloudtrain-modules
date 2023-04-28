locals {
  secret_name = "${local.db_instance_name}-${random_uuid.postgres.result}"
}

# create a SecretsManager secret to hold postgres username and password
resource aws_secretsmanager_secret postgres {
  name = local.secret_name
  kms_key_id = aws_kms_key.cmk.arn
  tags = merge({ Name = local.secret_name }, local.module_common_tags)
}

locals {
  secret_value = {
    postgresql-user = local.db_master_user_name
    postgresql-password = random_password.db_password.result
  }
}

# attach the JSON encoded secrets values to the SecretsManager secret
resource aws_secretsmanager_secret_version postgres {
  secret_id = aws_secretsmanager_secret.postgres.id
  secret_string = jsonencode(local.secret_value)
}

resource random_uuid postgres {

}