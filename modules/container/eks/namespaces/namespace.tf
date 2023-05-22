locals {
  namespace_names = [for nst in var.kubernetes_namespace_templates : nst.name ]
  namespaces_by_name = zipmap(local.namespace_names, var.kubernetes_namespace_templates)
}

resource kubernetes_namespace_v1 this {
  for_each = local.namespaces_by_name
  metadata {
    name = each.key
    labels = merge(each.value.labels, {
      "app.kubernetes.io/component" = "namespace"
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/name" = each.value.name
      "app.kubernetes.io/part-of" = var.solution_name
    })
  }
}