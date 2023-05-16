module "loadbalancer" {
  source = "../../loadbalancer"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = local.module_common_tags
  domain_name = var.host_name # TODO: consolidate
  loadbalancer_name = "default"
  loadbalancer_subnet_ids = var.loadbalancer_subnet_ids
  target_group_subnet_ids = var.target_group_subnet_ids
  tls_certificate_arn = var.tls_certificate_arn
  ingress_controller = module.nginx.ingress_controller
  eks_cluster_name = var.eks_cluster_name
}