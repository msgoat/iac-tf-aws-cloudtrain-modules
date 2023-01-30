output eks_cluster_arn {
  description = "Unique identifier of the AWS EKS cluster"
  value = aws_eks_cluster.control_plane.arn
}

output eks_cluster_name {
  description = "Name of the AWS EKS cluster"
  value = aws_eks_cluster.control_plane.name
}

output eks_node_group_iam_role_id {
  description = "Unique identifier attached to each EKS managed node group"
  value = aws_iam_role.node_group.id
}