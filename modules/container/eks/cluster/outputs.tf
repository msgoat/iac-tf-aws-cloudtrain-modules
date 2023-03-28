output eks_cluster_arn {
  description = "Unique identifier of the AWS EKS cluster"
  value = aws_eks_cluster.control_plane.arn
}

output eks_cluster_name {
  description = "Name of the AWS EKS cluster"
  value = aws_eks_cluster.control_plane.name
}

output eks_control_plane_iam_role_id {
  description = "Unique identifier of the IAM role attached to the EKS control plane"
  value = aws_iam_role.node_group.id
}

output eks_node_group_iam_role_id {
  description = "Unique identifier of the IAM role attached to each EKS managed node group"
  value = aws_iam_role.node_group.id
}

output iam_openid_connect_provider_id {
  description = "Unique identifier of the IAM OpenID Connect Provider associated with the EKS cluster"
  value = aws_iam_openid_connect_provider.this.id
}

output iam_openid_connect_provider_arn {
  description = "ARN of the IAM OpenID Connect Provider associated with the EKS cluster"
  value = aws_iam_openid_connect_provider.this.arn
}
