// retrieve the names of the node groups attached to the given EKS cluster
data "aws_eks_node_groups" "given" {
  cluster_name = var.eks_cluster_name
}

// retrieve the details of the node groups attached to the given EKS cluster
data "aws_eks_node_group" "given" {
  for_each = data.aws_eks_node_groups.given.names
  cluster_name = var.eks_cluster_name
  node_group_name = each.value
}
