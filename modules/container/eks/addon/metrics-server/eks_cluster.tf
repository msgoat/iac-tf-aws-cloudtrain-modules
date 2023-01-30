data "aws_eks_cluster" "given" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "given" {
  name = var.eks_cluster_name
}