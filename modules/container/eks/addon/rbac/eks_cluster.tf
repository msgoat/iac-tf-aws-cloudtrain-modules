data aws_eks_cluster given {
  name = var.eks_cluster_name
}

data aws_eks_cluster_auth given {
  name = data.aws_eks_cluster.given.name
}

data aws_eks_node_groups given {
  cluster_name = var.eks_cluster_name
}

data aws_eks_node_group given {
  for_each = data.aws_eks_node_groups.given.names
  cluster_name = var.eks_cluster_name
  node_group_name = each.value
}

locals {
  node_role_arns = [for ng in data.aws_eks_node_group.given : ng.node_role_arn]
}