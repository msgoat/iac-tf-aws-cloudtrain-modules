locals {
  eks_admin_role_name = "role-${data.aws_eks_cluster.given.name}-admin"
}

# Create a specific admin role for the given EKS cluster which any user of the current account and AWS CodeBuild is allowed to assume
resource "aws_iam_role" "eks_admin" {
  name               = local.eks_admin_role_name
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = merge({
    Name = local.eks_admin_role_name
  }, local.module_common_tags)
}

# Allow any access to the given EKS cluster
resource "aws_iam_role_policy" "eks_permissions" {
  role   = aws_iam_role.eks_admin.name
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowReadAccessOnAnyCluster",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeAddonConfiguration",
                "eks:ListClusters",
                "eks:DescribeAddonVersions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowAnyAccessOnSpecificCluster",
            "Effect": "Allow",
            "Action": "eks:*",
            "Resource": [
                "arn:aws:eks:${var.region_name}:${data.aws_caller_identity.current.account_id}:cluster/${data.aws_eks_cluster.given.name}",
                "arn:aws:eks:${var.region_name}:${data.aws_caller_identity.current.account_id}:addon/${data.aws_eks_cluster.given.name}/*/*",
                "arn:aws:eks:${var.region_name}:${data.aws_caller_identity.current.account_id}:identityproviderconfig/${data.aws_eks_cluster.given.name}/*/*/*",
                "arn:aws:eks:${var.region_name}:${data.aws_caller_identity.current.account_id}:nodegroup/${data.aws_eks_cluster.given.name}/*/*",
                "arn:aws:eks:${var.region_name}:${data.aws_caller_identity.current.account_id}:fargateprofile/${data.aws_eks_cluster.given.name}/*/*"
            ]
        }
    ]
}
POLICY
}
