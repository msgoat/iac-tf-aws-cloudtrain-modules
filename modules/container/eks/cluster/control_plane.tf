locals {
  eks_cluster_name = "eks-${var.region_name}-${var.solution_fqn}-${var.kubernetes_cluster_name}"
  cluster_security_group_ids = var.loadbalancer_security_group_enabled ? [ aws_security_group.cluster_shared_node[0].id ] : [ ]
}

resource aws_eks_cluster control_plane {
  name = local.eks_cluster_name
  role_arn = aws_iam_role.control_plane.arn
  version = var.kubernetes_version
  tags = merge({
    Name = local.eks_cluster_name
  }, local.module_common_tags)

  vpc_config {
    subnet_ids = var.node_group_subnet_ids
    endpoint_public_access = true
    endpoint_private_access = var.private_endpoint_enabled
    security_group_ids = local.cluster_security_group_ids
    public_access_cidrs = var.kubernetes_api_access_cidrs
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.cmk_secrets.arn
    }
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}
