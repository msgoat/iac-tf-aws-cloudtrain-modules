locals {
  oidc_provider_id  = substr(data.aws_eks_cluster.given.identity[0].oidc[0].issuer, length("https://"), length(data.aws_eks_cluster.given.identity[0].oidc[0].issuer))
  oidc_provider_arn = data.aws_iam_openid_connect_provider.given.arn
}

data "aws_iam_openid_connect_provider" "given" {
  url = data.aws_eks_cluster.given.identity[0].oidc[0].issuer
}
