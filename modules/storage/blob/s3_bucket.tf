locals {
  s3_bucket_name = "s3-${var.region_name}-${var.solution_fqn}-${var.bucket_name}"
}

// create s3 bucket as container for blobs
resource aws_s3_bucket blob {
  bucket = local.s3_bucket_name
  tags   = merge({ Name = local.s3_bucket_name }, local.module_common_tags)
}

// enable versioning on S3 bucket to be able to recover from unintended state changes
resource aws_s3_bucket_versioning blob {
  count  = var.versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.blob.id
  versioning_configuration {
    status = "Enabled"
  }
}

// block public access to bucket
resource aws_s3_bucket_public_access_block block_public_access {
  count                   = var.public_access_enabled ? 0 : 1
  bucket                  = aws_s3_bucket.blob.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// enable default encryption for data-at-rest with SSE-S3 encryption
resource aws_s3_bucket_server_side_encryption_configuration blob {
  bucket = aws_s3_bucket.blob.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"

      # Include kms_master_key_id if it's provided, otherwise exclude it
      dynamic "kms_master_key_id" {
        for_each = var.custom_encryption_kms_key_arn != null ? [1] : []
        content {
          kms_master_key_id = var.custom_encryption_kms_key_arn
        }
      }
    }
    bucket_key_enabled = true
  }
}

// optionally enable logging to a target bucket
resource aws_s3_bucket_logging main {
  count  = var.logging_bucket_name != null ? 1 : 0
  bucket = aws_s3_bucket.blob.id

  target_bucket = var.logging_bucket_name
  target_prefix = "bucket/${aws_s3_bucket.blob.bucket}"
}

// add a bucket policy which denies HTTP access
resource aws_s3_bucket_policy deny_http_access {
  bucket = aws_s3_bucket.blob.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Id        = "BUCKET-POLICY"
    Statement = [
      {
        Sid       = "EnforceTls"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          "${aws_s3_bucket.blob.arn}/*",
          "${aws_s3_bucket.blob.arn}",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
          NumericLessThan = {
            "s3:TlsVersion" : 1.2
          }
        }
      },
    ]
  })
}

resource aws_s3_bucket_policy Deny_cross_account_access {
  bucket = aws_s3_bucket.blob.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Id        = "BUCKET-POLICY"
    Statement = [
      {
        Sid       = "DenyCrossAccountAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          "${aws_s3_bucket.blob.arn}/*",
          "${aws_s3_bucket.blob.arn}",
        ]
        Condition = {
          StringNotEquals = {
            "aws:PrincipalAccount" = [data.aws_caller_identity.current.account_id]
          }
        }
      },
    ]
  })
}

resource aws_s3_bucket_policy deny_unencrypted_uploads {
  count  = var.deny_unencrypted_uploads == true ? 1 : 0
  bucket = aws_s3_bucket.blob.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Id        = "BUCKET-POLICY"
    Statement = [
      {
        Sid       = "DenyUnencryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = [
          "${aws_s3_bucket.blob.arn}/*",
          "${aws_s3_bucket.blob.arn}",
        ]
        Condition = {
          Null = {
            "s3:x-amz-server-side-encryption" = "true"
          }
          StringNotEqualsIfExists = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
    ]
  })
}
