# pulls the postgres secret from the secret manager and creates a kubernetes secret with the same data

data "aws_secretsmanager_secret_version" "postgres" {
  secret_id = module.postgres.db_secret_id
}

locals {
  sm_secret_values = jsondecode(data.aws_secretsmanager_secret_version.postgres.secret_string)
}

resource kubernetes_secret postgres {
  type = "Opaque"
  metadata {
    name = module.postgres.db_instance_name
    namespace = var.kubernetes_namespace
    labels = {
      "app.kubernetes.io/name" = module.postgres.db_instance_name
      "app.kubernetes.io/component" = "secret"
      "app.kubernetes.io/part-of" = var.solution_name
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
  # we are explicitly using binary_data with base64encode() to prevent sensitive data from showing up in terraform state
  binary_data = {
    postgresql-user = base64encode(local.sm_secret_values["postgresql-user"])
    postgresql-password = base64encode(local.sm_secret_values["postgresql-password"])
  }
}
