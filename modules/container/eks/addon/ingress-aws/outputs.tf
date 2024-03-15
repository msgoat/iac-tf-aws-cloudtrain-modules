output kubernetes_ingress_class_name {
  description = "Name of the Kubernetes ingress class assigned to this ingress controller"
  value = var.kubernetes_ingress_class_name
}

output kubernetes_default_ingress_class {
  description = "Indicates if this ingress controller is the default ingress controller on this cluster"
  value = var.kubernetes_default_ingress_class
}
