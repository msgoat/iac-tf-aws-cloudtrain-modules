# variables.tf

variable region_name {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type        = string
}

variable solution_name {
  description = "The name of the solution that owns all AWS resources."
  type        = string
}

variable solution_stage {
  description = "The name of the current environment stage."
  type        = string
}

variable solution_fqn {
  description = "The fully qualified name of the solution (i.e. solution_name + solution_stage in most cases)."
  type        = string
}

variable common_tags {
  description = "Common tags to be attached to all AWS resources."
  type        = map(string)
}

variable bucket_name {
  description = "Logical name of the S3 bucket; will be expanded to a fully qualified S3 bucket name"
  type        = string
}

variable versioning_enabled {
  description = "Controls if blobs should be versioned; default false"
  type        = bool
  default     = false
}

variable public_access_enabled {
  description = "Controls if blobs should be accessible via internet; default false"
  type        = bool
  default     = false
}

variable "logging_bucket_name" {
  description = "Name for an optional logging bucket"
  type        = string
  default     = null
}

variable "custom_encryption_kms_key_arn" {
  description = "ARN of the KMS key used for bucket encryption"
  type        = string
}

variable "deny_unencrypted_uploads" {
  description = "Attaches a S3 bucket policy to prevent unencrypted objects upload"
  type        = bool
  default     = true
}
