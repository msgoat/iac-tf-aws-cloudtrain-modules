locals {
  cert_manager_role_name   = "role-${data.aws_eks_cluster.given.name}-cert-manager"
  cert_manager_policy_name = "policy-${data.aws_eks_cluster.given.name}-cert-manager"
}

// Create a dedicated IAM role to be attached to the Kubernetes service account of the AWS Load Balancer Controller
resource "aws_iam_role" "cert_manager" {
  name               = local.cert_manager_role_name
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": {
              "Federated": "${local.oidc_provider_arn}"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
              "StringEquals": {
                  "${local.oidc_provider_id}:sub": "system:serviceaccount:${var.kubernetes_namespace_name}:cert-manager",
                  "${local.oidc_provider_id}:aud": "sts.amazonaws.com"
              }
          }
      }
  ]
}
POLICY
  tags = merge({
    Name = local.cert_manager_role_name
  }, local.module_common_tags)
}

resource "aws_iam_role_policy" "cert_manager" {
  name   = local.cert_manager_policy_name
  role   = aws_iam_role.cert_manager.name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "${data.aws_route53_zone.given.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
POLICY
}
