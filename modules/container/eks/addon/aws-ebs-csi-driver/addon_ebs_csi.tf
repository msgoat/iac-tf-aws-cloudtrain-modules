locals {
  oidc_provider_id = replace(data.aws_eks_cluster.given.identity[0].oidc[0].issuer, "https://", "")
}

resource aws_eks_addon aws_ebs_csi {
  addon_name = "aws-ebs-csi-driver"
  cluster_name = data.aws_eks_cluster.given.name
  service_account_role_arn = aws_iam_role.aws_ebs_csi_driver.arn
  tags = merge({
    Name = "${data.aws_eks_cluster.given.name}-aws-ebs-csi"
  }, local.module_common_tags)
}

resource aws_iam_role aws_ebs_csi_driver {
  name = "role-${data.aws_eks_cluster.given.name}-ebs-csi-driver"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider_id}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.oidc_provider_id}:aud": "sts.amazonaws.com",
          "${local.oidc_provider_id}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
POLICY
  tags = merge({
    Name =  "role-${data.aws_eks_cluster.given.name}-ebs-csi-driver"
  }, local.module_common_tags)
}

resource aws_iam_role_policy aws_ebs_csi_ec2 {
  name = "policy-${data.aws_eks_cluster.given.name}-ebs-csi-ec2"
  role = aws_iam_role.aws_ebs_csi_driver.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:DetachVolume",
        "ec2:ModifyVolume"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource aws_iam_role_policy aws_ebs_csi_kms {
  name = "policy-${data.aws_eks_cluster.given.name}-ebs-csi-kms"
  role = aws_iam_role.aws_ebs_csi_driver.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": ["${aws_kms_key.cmk_volumes.arn}"],
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.cmk_volumes.arn}"]
    }
  ]
}
POLICY
}
