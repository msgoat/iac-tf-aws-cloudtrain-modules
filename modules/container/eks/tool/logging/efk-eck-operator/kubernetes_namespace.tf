# create a namespace
resource kubernetes_namespace namespace {
  metadata {
    name = var.kubernetes_namespace_name
    labels = {
      "app.kubernetes.io/name" = var.kubernetes_namespace_name
      "app.kubernetes.io/component" = "namespace"
      "app.kubernetes.io/part-of" = var.solution_name
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
}
