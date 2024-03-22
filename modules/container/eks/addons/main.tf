# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

module "aws_auth" {
  source                       = "../addon/rbac"
  region_name                  = var.region_name
  solution_fqn                 = var.solution_fqn
  solution_name                = var.solution_name
  solution_stage               = var.solution_stage
  common_tags                  = var.common_tags
  eks_cluster_id               = var.eks_cluster_id
  eks_cluster_admin_role_names = var.eks_cluster_admin_role_names
}

module "aws_ebs_csi_driver" {
  count            = var.addon_aws_ebs_csi_driver_enabled ? 1 : 0
  source           = "../addon/aws-ebs-csi-driver"
  region_name      = var.region_name
  solution_fqn     = var.solution_fqn
  solution_name    = var.solution_name
  solution_stage   = var.solution_stage
  common_tags      = var.common_tags
  eks_cluster_id   = var.eks_cluster_id
}

module "metrics_server" {
  count          = var.addon_metrics_server_enabled ? 1 : 0
  source         = "../addon/metrics-server"
  region_name    = var.region_name
  solution_fqn   = var.solution_fqn
  solution_name  = var.solution_name
  solution_stage = var.solution_stage
  common_tags    = var.common_tags
  eks_cluster_id = var.eks_cluster_id
}

module "cluster_autoscaler" {
  count            = var.addon_cluster_autoscaler_enabled ? 1 : 0
  source           = "../addon/cluster-autoscaler"
  region_name      = var.region_name
  solution_fqn     = var.solution_fqn
  solution_name    = var.solution_name
  solution_stage   = var.solution_stage
  common_tags      = var.common_tags
  eks_cluster_id   = var.eks_cluster_id
}

module "cert_manager" {
  count                       = var.addon_cert_manager_enabled ? 1 : 0
  source                      = "../addon/cert-manager"
  region_name                 = var.region_name
  solution_fqn                = var.solution_fqn
  solution_name               = var.solution_name
  solution_stage              = var.solution_stage
  common_tags                 = var.common_tags
  eks_cluster_id              = var.eks_cluster_id
  hosted_zone_name            = var.hosted_zone_name
  letsencrypt_account_name    = var.letsencrypt_account_name
  prometheus_operator_enabled = var.addon_prometheus_enabled
}

module "ingress_aws" {
  count                       = var.addon_ingress_aws_enabled ? 1 : 0
  source                      = "../addon/ingress-aws"
  region_name                 = var.region_name
  solution_fqn                = var.solution_fqn
  solution_name               = var.solution_name
  solution_stage              = var.solution_stage
  common_tags                 = var.common_tags
  eks_cluster_id              = var.eks_cluster_id
  cert_manager_enabled        = var.addon_cert_manager_enabled
  prometheus_operator_enabled = var.addon_prometheus_enabled
  depends_on                  = [module.cert_manager]
}

locals {
  load_balancer_strategy = var.addon_ingress_aws_enabled ? (var.loadbalancer_id != "" ? "SERVICE_VIA_TARGET_GROUP_BINDING" : "INGRESS_VIA_ALB") : "SERVICE_VIA_NODE_PORT"
}

module "ingress_nginx" {
  count                           = var.addon_ingress_nginx_enabled ? 1 : 0
  source                          = "../addon/ingress-nginx"
  region_name                     = var.region_name
  solution_fqn                    = var.solution_fqn
  solution_name                   = var.solution_name
  solution_stage                  = var.solution_stage
  common_tags                     = var.common_tags
  eks_cluster_id                  = var.eks_cluster_id
  kubernetes_cluster_architecture = var.kubernetes_cluster_architecture
  cert_manager_enabled            = var.addon_cert_manager_enabled
  prometheus_operator_enabled     = var.addon_prometheus_enabled
  load_balancer_strategy          = local.load_balancer_strategy
  loadbalancer_id                 = var.loadbalancer_id
  loadbalancer_target_group_id    = var.loadbalancer_target_group_id
  host_names                      = var.host_names
  opentelemetry_enabled           = var.opentelemetry_enabled
  opentelemetry_collector_host    = var.opentelemetry_collector_host
  opentelemetry_collector_port    = var.opentelemetry_collector_port
  depends_on                      = [module.cert_manager, module.ingress_aws]
}

locals {
  actual_ingress_class_name      = var.addon_ingress_nginx_enabled ? module.ingress_nginx[0].kubernetes_ingress_class_name : (var.addon_ingress_aws_enabled ? module.ingress_aws[0].kubernetes_ingress_class_name : "")
  actual_ingress_controller_type = var.addon_ingress_nginx_enabled ? module.ingress_nginx[0].kubernetes_ingress_controller_type : (var.addon_ingress_aws_enabled ? module.ingress_aws[0].kubernetes_ingress_controller_type : "")
}

module "eck_operator" {
  count                       = var.addon_eck_operator_enabled ? 1 : 0
  source                      = "../addon/eck-operator"
  region_name                 = var.region_name
  solution_fqn                = var.solution_fqn
  solution_name               = var.solution_name
  solution_stage              = var.solution_stage
  common_tags                 = var.common_tags
  eks_cluster_id              = var.eks_cluster_id
  cert_manager_enabled        = var.addon_cert_manager_enabled
  prometheus_operator_enabled = var.addon_prometheus_enabled
}
