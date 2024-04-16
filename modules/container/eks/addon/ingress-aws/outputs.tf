output "kubernetes_ingress_class_name" {
  description = "Kubernetes ingress class name assigned to this ingress controller"
  value       = var.kubernetes_ingress_class_name
}

output "kubernetes_ingress_controller_type" {
  description = "Kubernetes ingress controller type of this ingress controller"
  value       = "AWS"
}

output "helm_release_id" {
  description = "Unique identifier of the helm release managing this ingress controller"
  value       = helm_release.controller.id
}