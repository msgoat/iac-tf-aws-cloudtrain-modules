# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

module aws_auth {
  source = "../addon/rbac"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
  eks_cluster_admin_role_names = var.eks_cluster_admin_role_names
}

module aws_ebs_csi_driver {
  count = var.addon_aws_ebs_csi_driver_enabled ? 1 : 0
  source = "../addon/aws-ebs-csi-driver"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
}

module metrics_server {
  count = var.addon_metrics_server_enabled ? 1 : 0
  source = "../addon/metrics-server"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
}

module cluster_autoscaler {
  count = var.addon_cluster_autoscaler_enabled ? 1 : 0
  source = "../addon/cluster-autoscaler"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
}

module prometheus {
  count = var.addon_prometheus_enabled ? 1 : 0
  source = "../addon/prometheus"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
  cert_manager_enabled = false
}

module cert_manager {
  count = var.addon_cert_manager_enabled ? 1 : 0
  source = "../addon/cert-manager"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
  hosted_zone_name = var.hosted_zone_name
  letsencrypt_account_name = var.letsencrypt_account_name
  prometheus_operator_enabled = var.addon_prometheus_enabled
}

module aws_load_balancer_controller {
  count = var.addon_aws_load_balancer_controller_enabled ? 1 : 0
  source = "../addon/aws-load-balancer-controller"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
  cert_manager_enabled = var.addon_cert_manager_enabled
  depends_on = [ module.cert_manager ]
  prometheus_operator_enabled = var.addon_prometheus_enabled
}
