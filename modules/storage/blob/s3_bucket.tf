locals {
  s3_bucket_name = "s3-${var.region_name}-${var.solution_fqn}-${var.bucket_name}"
}

// create s3 bucket as container for blobs
resource aws_s3_bucket blob {
  tags = merge({Name = local.s3_bucket_name}, local.module_common_tags)
}

// enable versioning on S3 bucket to be able to recover from unintended state changes
resource aws_s3_bucket_versioning blob {
  count = var.versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.blob.id
  versioning_configuration {
    status = "Enabled"
  }
}

// block public access to bucket
resource aws_s3_bucket_public_access_block block_public_access {
  count = var.public_access_enabled ? 0 : 1
  bucket = aws_s3_bucket.blob.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// enable default encryption for data-at-rest with SSE-S3 encryption
resource aws_s3_bucket_server_side_encryption_configuration blob {
  bucket = aws_s3_bucket.blob.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

// add a bucket policy which denies HTTP access
resource aws_s3_bucket_policy deny_http_access {
  bucket = aws_s3_bucket.blob.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "BUCKET-POLICY"
    Statement = [
      {
        Sid       = "EnforceTls"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.blob.arn}/*",
          "${aws_s3_bucket.blob.arn}",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
          NumericLessThan = {
            "s3:TlsVersion": 1.2
          }
        }
      },
    ]
  })
}