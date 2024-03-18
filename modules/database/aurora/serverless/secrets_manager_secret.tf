# create a SecretsManager secret to hold postgres username and password
resource aws_secretsmanager_secret this {
  name = local.db_cluster_name
  kms_key_id = aws_kms_key.cmk.arn
  tags = merge({ Name = local.db_cluster_name }, local.module_common_tags)
}

locals {
  secret_value = {
    master-user = aws_rds_cluster.this.master_username
    master-password = aws_rds_cluster.this.master_password
  }
}

# attach the JSON encoded secrets values to the SecretsManager secret
resource aws_secretsmanager_secret_version this {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(local.secret_value)
}