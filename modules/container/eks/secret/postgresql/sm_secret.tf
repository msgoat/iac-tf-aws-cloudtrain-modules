data aws_secretsmanager_secret_version given {
  secret_id = var.sm_secret_id
}

locals {
  sms_secret_value = jsondecode(data.aws_secretsmanager_secret_version.given.secret_string)
}