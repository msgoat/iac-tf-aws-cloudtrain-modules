locals {
  secret_name = "grafana-${var.solution_fqn}-${random_uuid.secret_suffix.result}"
}

# create a SecretsManager secret to hold Grafana admin username and password
resource aws_secretsmanager_secret grafana {
  name = local.secret_name
  tags = merge({ Name = local.secret_name }, local.module_common_tags)
}

locals {
  secret_value = {
    grafana-admin-user = random_string.grafana_admin.result
    grafana-admin-password = random_password.grafana_admin.result
  }
}

# attach the JSON encoded secrets values to the SecretsManager secret
resource aws_secretsmanager_secret_version grafana {
  secret_id = aws_secretsmanager_secret.grafana.id
  secret_string = jsonencode(local.secret_value)
}

resource random_uuid secret_suffix {

}