resource kubernetes_secret grafana_admin {
  type = "Opaque"
  metadata {
    name = "grafana-admin"
    namespace = var.kubernetes_namespace_owned ? kubernetes_namespace_v1.this[0].metadata[0].name : var.kubernetes_namespace_name
    labels = {
      "app.kubernetes.io/name" = "grafana-admin"
      "app.kubernetes.io/instance" = "grafana-admin"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/part-of" = "grafana"
    }
  }
  binary_data = {
    grafana-admin-user = base64encode(random_string.grafana_admin.result)
    grafana-admin-password = base64encode(random_password.grafana_admin.result)
  }
}