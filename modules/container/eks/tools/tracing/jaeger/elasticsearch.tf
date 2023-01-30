module elasticsearch {
  source = "../../../kubernetes/database/elasticsearch"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = local.module_common_tags
  eks_cluster_name = var.eks_cluster_name
  kubernetes_namespace_name = var.kubernetes_namespace_name
  elasticsearch_cluster_name = "es-tracing"
  elasticsearch_storage_size = "50Gi"
}