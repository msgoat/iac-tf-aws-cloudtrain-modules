# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.63"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19"
    }
  }
}

module metrics_server {
  source = "../addon/metrics-server"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
}

module aws_ebs_csi_driver {
  source = "../addon/aws-ebs-csi-driver"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
}

module cluster_autoscaler {
  source = "../addon/cluster-autoscaler"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
}

module cert_manager {
  source = "../addon/cert-manager"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
  hosted_zone_name = var.hosted_zone_name
  letsencrypt_account_name = var.letsencrypt_account_name
}

module aws_load_balancer_controller {
  source = "../addon/aws-load-balancer-controller"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
  cert_manager_enabled = var.cert_manager_enabled
  depends_on = [ module.cert_manager ]
}
