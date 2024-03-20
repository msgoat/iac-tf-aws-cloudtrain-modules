output "ingress_controller" {
  description = "Metadata defining the endpoints of the newly created ingress controller"
  value = {
    name                       = "nginx"
    type                       = "NGINX"
    protocol                   = "HTTP"
    port                       = 32080
    health_probe_path          = "/healthz"
    health_probe_protocol      = "HTTP"
    health_probe_port          = 32080
    health_probe_success_codes = ["200", "404"]
  }
}

output "kubernetes_ingress_class_name" {
  description = "Kubernetes ingress class name assigned to this ingress controller"
  value       = var.kubernetes_ingress_class_name
}

output "kubernetes_ingress_controller_type" {
  description = "Kubernetes ingress controller type of this ingress controller"
  value       = "NGINX"
}