# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

module monitoring {
  source = "../tool/monitoring/kube-prometheus-stack"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
  grafana_host_name = var.domain_name
  grafana_path = "/grafana"
}

module eck_operator {
  source = "../tool/eck-operator"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
}
