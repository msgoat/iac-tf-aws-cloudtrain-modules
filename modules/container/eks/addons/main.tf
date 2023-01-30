# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module aws_ebs_csi {
  source = "../addon/aws-ebs-csi-driver"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
  addon_enabled = var.addon_aws_ebs_csi_enabled
}

module metrics_server {
  source = "../addon/metrics-server"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
  addon_enabled = var.addon_aws_ebs_csi_enabled
}

module cluster_autoscaler {
  source = "../addon/cluster-autoscaler"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = var.common_tags
  eks_cluster_name = var.eks_cluster_name
  addon_enabled = var.addon_aws_ebs_csi_enabled
}