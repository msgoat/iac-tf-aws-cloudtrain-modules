locals {
  kms_key_name        = "cmk-${local.db_cluster_name}"
  kms_key_policy_name = "policy-cmk-${local.db_cluster_name}-access"
}

# create a customer managed key to encrypt postgres data at rest and to encrypt postgres secrets
resource "aws_kms_key" "cmk" {
  description              = "customer master key of AWS Aurora instance ${local.db_cluster_name}"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "AllowUpdateThroughIaC",
          Effect = "Allow",
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          Action = [ "kms:*" ],
          Resource = "*"
        },
        {
          Sid      = "AllowCMKAccessFromRDSAurora"
          Effect   = "Allow"
          Principal = "*"
          Action   = ["kms:GenerateDataKey", "kms:Decrypt"]
          Resource = "*"
          Condition = {
            StringEquals = {
              "kms:ViaService" = ["rds.${var.region_name}.amazonaws.com"]
            }
          }
        },
        {
          Sid      = "AllowCMKAccessFromSecretsManager"
          Effect   = "Allow"
          Principal = "*"
          Action   = ["kms:GenerateDataKey", "kms:Decrypt"]
          Resource = "*"
          Condition = {
            StringEquals = {
              "kms:ViaService" = ["secretsmanager.${var.region_name}.amazonaws.com"]
            }
          }
        }
      ]
    }
  )
  tags = merge({
    Name = local.kms_key_name
  }, local.module_common_tags)
}

resource "aws_kms_alias" "cmk" {
  name          = "alias/${local.kms_key_name}"
  target_key_id = aws_kms_key.cmk.id
}
