provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.given.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.given.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.given.token
  }
}