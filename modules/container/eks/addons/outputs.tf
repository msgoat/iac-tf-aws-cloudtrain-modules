output "kubernetes_ingress_class_name" {
  description = "Kubernetes ingress class name of the default ingress controller"
  value       = local.actual_ingress_class_name
}

output "kubernetes_ingress_controller_type" {
  description = "Kubernetes ingress controller type of the default ingress controller"
  value       = local.actual_ingress_controller_type
}