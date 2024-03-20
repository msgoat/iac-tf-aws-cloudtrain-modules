output "kubernetes_namespaces" {
  description = "Names of all created Kubernetes namespaces"
  value       = local.result_namespace_names
}