# openid_connect_provider.tf
# ----------------------------------------------------------------------------
# Creates an IAM OpenID Connect Provider for the EKS cluster
# ----------------------------------------------------------------------------

data "tls_certificate" "this" {
  url = aws_eks_cluster.control_plane.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.this.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.this.url
  tags = merge({
    Name = "oidc-${var.region_name}-${var.solution_fqn}-${var.kubernetes_cluster_name}-eks"
  }, local.module_common_tags)
}
