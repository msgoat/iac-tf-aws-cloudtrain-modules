locals {
  target_namespace_names = [for nst in var.kubernetes_namespace_templates : nst.name if nst.network_policy_enforced]
  network_policy_labels = {
    "app.kubernetes.io/name" = "deny-all-ingress"
    "app.kubernetes.io/component" = "network"
    "app.kubernetes.io/part-of" = var.solution_name
    "app.kubernetes.io/managed-by" = "Terraform"
  }
}

resource kubernetes_network_policy_v1 deny_all_ingress {
  for_each = toset(local.target_namespace_names)
  metadata {
    name = "deny-all-ingress"
    namespace = kubernetes_namespace_v1.this[each.value].metadata[0].name
    labels = local.network_policy_labels
  }
  spec {
    policy_types = ["Ingress"]
    pod_selector {}
  }
}