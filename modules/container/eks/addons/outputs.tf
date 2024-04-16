output "kubernetes_ingress_class_name" {
  description = "Kubernetes ingress class name of the default ingress controller"
  value       = local.actual_ingress_class_name
}

output "kubernetes_ingress_controller_type" {
  description = "Kubernetes ingress controller type of the default ingress controller"
  value       = local.actual_ingress_controller_type
}

output "production_cluster_certificate_issuer_name" {
  description = "Name of the production cluster issuer for TLS certificates"
  value       = var.addon_cert_manager_enabled ? module.cert_manager[0].production_cluster_certificate_issuer_name : null
}

output "test_cluster_certificate_issuer_name" {
  description = "Name of the test cluster issuer for TLS certificates"
  value       = var.addon_cert_manager_enabled ? module.cert_manager[0].test_cluster_certificate_issuer_name : null
}