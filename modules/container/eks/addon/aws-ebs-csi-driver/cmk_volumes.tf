locals {
  kms_key_name_volumes = "cmk-${data.aws_eks_cluster.given.name}-volumes"
}

resource "aws_kms_key" "cmk_volumes" {
  description              = "customer master key for EBS volumes of AWS EKS cluster ${data.aws_eks_cluster.given.name}"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7

  tags = merge({
    Name = local.kms_key_name_volumes
  }, local.module_common_tags)
}

resource "aws_kms_alias" "cmk_volumes" {
  name          = "alias/${local.kms_key_name_volumes}"
  target_key_id = aws_kms_key.cmk_volumes.id
}

/*
resource aws_kms_grant cmk_volumes {
  name = "kms-grant-${local.eks_cluster_name}-control-plane"
  grantee_principal = aws_iam_role.control_plane.arn
  key_id = aws_kms_key.cmk_volumes.id
  operations = [
    "Decrypt",
    "Encrypt",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "ReEncryptFrom",
    "ReEncryptTo",
    "DescribeKey",
    "GenerateDataKeyPair",
    "GenerateDataKeyPairWithoutPlaintext"
  ]
}
*/