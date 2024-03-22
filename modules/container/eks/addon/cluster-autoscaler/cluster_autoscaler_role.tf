locals {
  autoscaler_role_name   = "role-${var.eks_cluster_name}-autoscaler"
  autoscaler_policy_name = "policy-${var.eks_cluster_name}-autoscaler"
}

// Create a dedicated IAM role to be attached to the Kubernetes service account of the cluster autoscaler
resource "aws_iam_role" "cluster_autoscaler" {
  name               = local.autoscaler_role_name
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
                  "${local.oidc_provider_id}:sub": "system:serviceaccount:${var.kubernetes_namespace_name}:aws-cluster-autoscaler",
                  "${local.oidc_provider_id}:aud": "sts.amazonaws.com"
              }
          }
      }
  ]
}
POLICY
  tags = merge({
    Name = local.autoscaler_role_name
  }, local.module_common_tags)
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  name   = local.autoscaler_policy_name
  role   = aws_iam_role.cluster_autoscaler.name
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowClusterAutoScalerToReadNodeGroups",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DescribeTags",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeImages",
                "ec2:GetInstanceTypesFromInstanceRequirements",
                "eks:DescribeNodegroup"
            ],
            "Resource": ["*"]
        },
        {
            "Sid": "AllowClusterAutoScalerToUpdateNodeGroups",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled": "true",
                    "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.eks_cluster_name}": "owned"
                }
            }
        }
    ]
}
POLICY
}
