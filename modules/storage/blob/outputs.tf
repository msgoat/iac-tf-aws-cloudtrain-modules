output s3_bucket_id {
  description = "Unique identifier of the S3 bucket providing blob storage"
  value = aws_s3_bucket.blob.id
}

output s3_bucket_arn {
  description = "Amazon resource name of the S3 bucket providing blob storage as used in policies"
  value = aws_s3_bucket.blob.arn
}

output s3_bucket_name {
  description = "Fully qualified name of the S3 bucket providing blob storage"
  value = aws_s3_bucket.blob.bucket
}
