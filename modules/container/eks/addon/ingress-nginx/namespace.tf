locals {
  default_labels = {
    "app.kubernetes.io/component"             = "controller"
    "app.kubernetes.io/instance"              = var.helm_release_name
    "app.kubernetes.io/managed-by"            = "Terraform"
    "app.kubernetes.io/name"                  = var.kubernetes_namespace_name
    "app.kubernetes.io/part-of"               = var.helm_release_name
    "elbv2.k8s.aws/pod-readiness-gate-inject" = var.loadbalancer_target_type == "ip" ? "enabled" : "disabled"
  }
}

resource "kubernetes_namespace_v1" "nginx" {
  count = var.kubernetes_namespace_owned ? 1 : 0
  metadata {
    name   = var.kubernetes_namespace_name
    labels = local.default_labels
  }
}