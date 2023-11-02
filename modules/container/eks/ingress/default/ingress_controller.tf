module "nginx" {
  source = "../nginx2"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = local.module_common_tags
  eks_cluster_name = var.eks_cluster_name
  cert_manager_enabled = var.cert_manager_enabled
  default_ingress_class = true
  host_name = var.host_name
  load_balancer_strategy = "SERVICE_VIA_NODE_PORT"
  prometheus_operator_enabled = var.prometheus_operator_enabled
  jaeger_enabled = var.jaeger_enabled
  jaeger_agent_host = var.jaeger_agent_host
  jaeger_agent_port = var.jaeger_agent_port
}