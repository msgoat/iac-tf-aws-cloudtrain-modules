# retrieve all autoscaling groups representing managed node groups of the given EKS cluster
data aws_autoscaling_groups node_groups {
  filter {
    name = "key"
    values = ["eks:cluster-name"]
  }
  filter {
    name = "value"
    values = [var.eks_cluster_name]
  }
}