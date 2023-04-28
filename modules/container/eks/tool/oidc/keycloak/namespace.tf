# create a default namespace for the monitoring stack
module namespace {
  source = "../../namespace"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = local.module_common_tags
  kube_config_file_name = var.kube_config_file_name
  kubernetes_namespace_name = var.kubernetes_namespace_name
  istio_injection_enabled = false
  network_policy_enforced = false
}