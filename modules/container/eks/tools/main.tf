# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

module "monitoring" {
  source                             = "../tool/monitoring/kube-prometheus-stack"
  region_name                        = var.region_name
  solution_fqn                       = var.solution_fqn
  solution_name                      = var.solution_name
  solution_stage                     = var.solution_stage
  common_tags                        = var.common_tags
  eks_cluster_id                     = var.eks_cluster_id
  kubernetes_ingress_class_name      = var.kubernetes_ingress_class_name
  kubernetes_ingress_controller_type = var.kubernetes_ingress_controller_type
  grafana_host_name                  = var.domain_name
  grafana_path                       = "/grafana"
}

module "logging" {
  source                             = "../tool/logging/efk-eck-operator"
  region_name                        = var.region_name
  solution_fqn                       = var.solution_fqn
  solution_name                      = var.solution_name
  solution_stage                     = var.solution_stage
  common_tags                        = var.common_tags
  eks_cluster_id                     = var.eks_cluster_id
  kubernetes_ingress_class_name      = var.kubernetes_ingress_class_name
  kubernetes_ingress_controller_type = var.kubernetes_ingress_controller_type
  kibana_host_name                   = var.domain_name
  kibana_path                        = "/kibana"
  cert_manager_enabled               = var.cert_manager_enabled
  prometheus_operator_enabled        = var.prometheus_operator_enabled
}

module "tracing" {
  source                             = "../tool/tracing/jaeger"
  region_name                        = var.region_name
  solution_fqn                       = var.solution_fqn
  solution_name                      = var.solution_name
  solution_stage                     = var.solution_stage
  common_tags                        = var.common_tags
  eks_cluster_id                     = var.eks_cluster_id
  kubernetes_ingress_class_name      = var.kubernetes_ingress_class_name
  kubernetes_ingress_controller_type = var.kubernetes_ingress_controller_type
  jaeger_host_name                   = var.domain_name
  jaeger_path                        = "/jaeger"
  cert_manager_enabled               = var.cert_manager_enabled
  prometheus_operator_enabled        = var.prometheus_operator_enabled
}
