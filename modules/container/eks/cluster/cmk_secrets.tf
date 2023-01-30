locals {
  kms_key_name_secrets = "cmk-${local.eks_cluster_name}-secrets"
}

resource aws_kms_key cmk_secrets {
  description = "customer master key for Kubernetes secrets of AWS EKS cluster ${local.eks_cluster_name}"
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 7

  tags = merge({
    Name = local.kms_key_name_secrets
  }, local.module_common_tags)
}

resource aws_kms_alias cmk {
  name = "alias/${local.kms_key_name_secrets}"
  target_key_id = aws_kms_key.cmk_secrets.id
}

resource aws_kms_grant cmk {
  name = "kms-grant-${local.eks_cluster_name}-control-plane"
  grantee_principal = aws_iam_role.control_plane.arn
  key_id = aws_kms_key.cmk_secrets.id
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
