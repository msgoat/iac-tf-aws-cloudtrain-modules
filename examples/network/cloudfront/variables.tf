variable region_name {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type        = string
  default     = "eu-west-1"
}

variable solution_name {
  description = "The name of the AWS solution that owns all AWS resources."
  type        = string
  default     = "ctraintest"
}

variable solution_stage {
  description = "The name of the current AWS solution stage."
  type        = string
  default     = "dev"
}

variable solution_fqn {
  description = "The fully qualified name of the current AWS solution."
  type        = string
  default     = "ctraintest-dev"
}

variable common_tags {
  description = "Common tags to be attached to all AWS resources"
  type        = map(string)
  default     = {
    Organization = "msg systems ag"
    BusinessUnit = "Branche Automotive + Manufacturing"
    Department   = "AT2"
    Solution     = "CloudTrain Test"
    Stage        = "dev"
    ManagedBy    = "Terraform"
  }
}

variable bucket_name {
  description = "The logical name of the S3 bucket."
  type        = string
}

variable "deny_unencrypted_uploads" {
  description = "Controls if uploads of unencrypted objects are denied. Default: unencrypted uploads are denied."
  type        = bool
}