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
  type        = string
  description = "Name of the API Gateway"
}

variable "stage" {
  type        = string
  description = "Name of the stage"
}

variable "type" {
  type        = string
  description = "Endpoint type. Valid values: EDGE, REGIONAL or PRIVATE. If unspecified defaults to EDGE."
  default     = "EDGE"

  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.type)
    error_message = "Allowed values for input_parameter are \"EDGE\", \"REGIONAL\", or \"PRIVATE\"."
  }
}

variable "paths" {
  type = list(object({
    method      = string
    path        = string # must start with /
    type        = string # must be one of MOCK, AWS, AWS_PROXY, HTTP or HTTP_PROXY
    destination = string
    # in case of type AWS or AWS_PROXY must be aws arn. For HTTP or HTTP_PROXY, this is the URL of the HTTP endpoint including the https or http scheme.
  }))

  validation {
    condition     = length(var.paths[*].type) > 0 && alltrue([
    for obj in var.paths : contains([
      "MOCK", "AWS", "AWS_PROXY", "HTTP", "HTTP_PROXY"
    ], obj.type)
    ])
    error_message = "Allowed values for input_parameter paths.type are \"MOCK\", \"AWS\", \"AWS_PROXY\", \"HTTP\" or \"HTTP_PROXY\"."
  }

  validation {
    condition     = length(var.paths[*].path) > 0 && alltrue([for obj in var.paths : startswith(obj.path, "/")])
    error_message = "type must start with a forward slash (/)"
  }
}

