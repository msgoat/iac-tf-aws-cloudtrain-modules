locals {
  raw_secret_data = merge({
    postgresql-host = data.aws_db_instance.given.address
    postgresql-port = data.aws_db_instance.given.port
    postgresql-database = data.aws_db_instance.given.db_name
  }, local.sms_secret_value)
  encoded_secret_data = {for k,v in local.raw_secret_data : k => base64encode(v)}
}

resource kubernetes_secret_v1 this {
  for_each = toset(var.kubernetes_namespace_names)
  type = "Opaque"
  metadata {
    name = local.db_instance_name
    namespace = each.value
    labels = {
      "app.kubernetes.io/name" = local.db_instance_name
      "app.kubernetes.io/instance" = local.db_instance_name
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/part-of" = var.solution_name
    }
  }
  binary_data = local.encoded_secret_data
}