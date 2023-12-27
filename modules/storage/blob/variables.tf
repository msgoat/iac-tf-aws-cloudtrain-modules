# variables.tf

variable "region_name" {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type        = string
}

variable "solution_name" {
  description = "The name of the solution that owns all AWS resources."
  type        = string
}

variable "solution_stage" {
  description = "The name of the current environment stage."
  type        = string
}

variable "solution_fqn" {
  description = "The fully qualified name of the solution (i.e. solution_name + solution_stage in most cases)."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be attached to all AWS resources."
  type        = map(string)
}

variable "bucket_name" {
  description = "Logical name of the S3 bucket; will be expanded to a fully qualified S3 bucket name"
  type        = string
}

variable "versioning_enabled" {
  description = "Controls if blobs should be versioned. Default: no versioning."
  type        = bool
  default     = false
}

variable "public_access_enabled" {
  description = "Controls if blobs should be accessible via internet. Default: no public access."
  type        = bool
  default     = false
}

variable "logging_bucket_name" {
  description = "Optional name for a logging bucket; triggers creation of an additional logging bucket, if specified. Default: no logging."
  type        = string
  default     = null
}

variable "custom_encryption_kms_key_arn" {
  description = "Optional identifier of a customer-managed-key; triggers server-side encryption with customer-managed keys, if specified. Default: AWS managed keys."
  type        = string
  default     = null
}

variable "deny_unencrypted_uploads" {
  description = "Controls if uploads of unencrypted objects are denied. Default: unencrypted uploads are denied."
  type        = bool
  default     = true
}

variable "deny_cross_account_access" {
  description = "Controls if cross-account access is denied. Default: Cross-account access is denied."
  type        = bool
  default     = true
}
