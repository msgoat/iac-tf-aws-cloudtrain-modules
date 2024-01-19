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

variable "name" {
  description = "Name of the Lambda function."
  type        = string
}

variable "description" {
  description = "Description of the Lambda function."
  type        = string
}

variable "runtime" {
  description = "Runtime of the Lambda function."
  type        = string
}

variable "architectures" {
  description = "Architectures of the Lambda function. Defaults to [\"x86_64\"]."
  type        = list(string)
  default     = ["x86_64"]
}

variable "memory_size" {
  description = "Memory Size of the Lambda function. Defaults to 128."
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables of the Lambda functions."
  type        = map(string)
  default     = {}
}

variable "filename" {
  description = "(Optional) Path to the function's deployment package within the local filesystem. Exactly one of filename, image_uri or s3_bucket must be specified."
  type        = string
  default     = null
}

variable "image_uri" {
  description = "(Optional) ECR image URI containing the function's deployment package. Exactly one of filename, image_uri or s3_bucket must be specified."
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "(Optional) S3 bucket location containing the function's deployment package. This bucket must reside in the same AWS region where you are creating the Lambda function. Exactly one of filename, image_uri, or s3_bucket must be specified. When s3_bucket is set, s3_key is required."
  type        = string
  default     = null
}

variable "s3_key" {
  description = "(Optional) S3 key of an object containing the function's deployment package. When s3_bucket is set, s3_key is required."
  type        = string
  default     = null
}

variable "handler" {
  description = "Function entrypoint in your code."
  type        = string
}

variable "event_source" {
  type        = string
  description = "Lambda event source, allowed values are sns, sqs, api or null"

  default = "none"

  validation {
    condition     = contains([
      "sqs", "sns", "api", "none"
    ], var.event_source)
    error_message = "Allowed values for input_parameter are \"sqs\", \"sns\", \"api\" or \"none\"."
  }
}

variable "events" {
  description = "Lambda event trigger."
  type        = object({
    sqs = string # arn of the sqs queue
    sns = string # arn of the sns topic
    api = object({
      id     = string # id of the api gateway
      name   = string # name of the api gateway
      method = string # http method
      path   = string # http path, must start with /
    })
  })
  default     = {
    sqs = null
    sns = null
    api = null
  }
}