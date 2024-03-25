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
  grafana_host_name                  = var.grafana_host_name
  grafana_path                       = var.grafana_path
  ensure_high_availability           = var.ensure_high_availability
  node_group_workload_class          = var.node_group_workload_class
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
  kibana_host_name                   = var.kibana_host_name
  kibana_path                        = var.kibana_path
  cert_manager_enabled               = var.cert_manager_enabled
  prometheus_operator_enabled        = var.prometheus_operator_enabled
  ensure_high_availability           = var.ensure_high_availability
  node_group_workload_class          = var.node_group_workload_class
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
  jaeger_host_name                   = var.jaeger_host_name
  jaeger_path                        = var.jaeger_path
  cert_manager_enabled               = var.cert_manager_enabled
  prometheus_operator_enabled        = var.prometheus_operator_enabled
  ensure_high_availability           = var.ensure_high_availability
  node_group_workload_class          = var.node_group_workload_class
}
