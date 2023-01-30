locals {
  node_group_role_names = distinct([ for ng in data.aws_eks_node_group.given : split("/", ng.node_role_arn)[1] ])
  autoscaler_policy_name = "policy-${var.eks_cluster_name}-autoscaler"
}

// attach the policy with all permissions required by the cluster autoscaler to each node group IAM role
resource aws_iam_role_policy cluster_autoscaler {
  for_each = toset(local.node_group_role_names)
  name = local.autoscaler_policy_name
  role = each.value
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
POLICY
}
