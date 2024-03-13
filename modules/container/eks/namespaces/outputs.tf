output kubernetes_namespaces {
  description = "Names of all created Kubernetes namespaces"
  value = kubernetes_namespace_v1.this.*.metadata[0].name
}