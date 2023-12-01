# storage/blob 

Terraform module to create a S3 bucket supposed to be used for blob storage.

The newly created S3 bucket has the following properties:

* Public access is blocked by default (but can be enabled through variable `public_access_enabled`)
* Data at rest is encrypted using an AWS managed key (SSE-S3) (customer managed keys (SSE-KMS) can be added through variable `custom_encryption_kms_key_arn`)
* Versioning is disabled (but can be enabled through variable `versioning_enabled`)
* Denying unencrypted uploads is enabled (but can be disabled through variable `deny_unencrypted_uploads`)
* A logging bucket can be added through variable `logging_bucket_name`

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

