# variables.tf

variable region_name {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type = string
}

variable solution_name {
  description = "The name of the solution that owns all AWS resources."
  type = string
}

variable solution_stage {
  description = "The name of the current environment stage."
  type = string
}

variable solution_fqn {
  description = "The fully qualified name of the solution (i.e. solution_name + solution_stage in most cases)."
  type = string
}

variable common_tags {
  description = "Common tags to be attached to all AWS resources."
  type = map(string)
}

variable bucket_name {
  description = "Logical name of the S3 bucket; will be expanded to a fully qualified S3 bucket name"
  type = string
}

variable versioning_enabled {
  description = "Controls if blobs should be versioned; default false"
  type = bool
  default = false
}

variable public_access_enabled {
  description = "Controls if blobs should be accessible via internet; default false"
  type = bool
  default = false
}

variable custom_encryption_enabled {
  description = "Controls if blobs should be encrypted using a customer managed key in KMS; default false"
  type = bool
  default = false
}