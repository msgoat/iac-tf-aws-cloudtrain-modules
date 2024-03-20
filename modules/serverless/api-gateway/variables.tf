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
    public      = optional(bool, false) # indicating if the authorizer should be used for this method
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

variable "authorizer" {
  type        = object({
    authorization     = string
    # Authorization type. Valid values: NONE, CUSTOM or COGNITO_USER_POOLS. If unspecified defaults to NONE.
    name              = string
    type              = string
    # Type of the Authorizer. Possible values for CUSTOM authorization are TOKEN and REQUEST. Possible value for COGNITO_USER_POOLS authorization is COGNITO_USER_POOLS.
    user_pool_arn     = optional(string, null)
    # (Optional, required for type COGNITO_USER_POOLS) ARN of the cognito user pool
    lambda_invoke_arn = optional(string, null)
    # Optional, required for authorization CUSTOM) Invoke ARN of the custom lambda authorizer function
    lambda_arn        = optional(string, null)
    # Optional, required for authorization CUSTOM) ARN of the custom lambda authorizer function
  })
  description = "Authorization type. Valid values: NONE, CUSTOM or COGNITO_USER_POOLS. If unspecified defaults to NONE."
  default     = {
    authorization     = "NONE"
    name              = null
    type              = null
    user_pool_arn     = null
    lambda_invoke_arn = null
    lambda_arn        = null
  }

  validation {
    condition     = contains(["NONE", "CUSTOM", "COGNITO_USER_POOLS"], var.authorizer.authorization)
    error_message = "Allowed values for input_parameter authorizer.authorization are \"NONE\", \"CUSTOM\" or \"COGNITO_USER_POOLS\"."
  }

  validation {
    condition     = (var.authorizer.authorization == "NONE" && var.authorizer.type == null) || ((var.authorizer.type == "TOKEN" || var.authorizer.type == "REQUEST") && var.authorizer.authorization == "CUSTOM" || var.authorizer.type == "COGNITO_USER_POOLS" && var.authorizer.authorization == "COGNITO_USER_POOLS")
    error_message = "Allowed values for input_parameter authorizer.type are \"TOKEN\" or \"REQUEST\" when authorizer.authorization is \"CUSTOM\" or \"COGNITO_USER_POOLS\" when authorizer.authorization is \"COGNITO_USER_POOLS\"."
  }

  validation {
    condition     = var.authorizer.authorization != "COGNITO_USER_POOLS" || var.authorizer.user_pool_arn != null
    error_message = "authorizer.user_pool_arn can not be null when authorizer.authorization is equal to COGNITO_USER_POOLS"
  }

  validation {
    condition     = var.authorizer.authorization != "CUSTOM" || var.authorizer.lambda_invoke_arn != null
    error_message = "authorizer.lambda_invoke_arn can not be null when authorizer.authorization is equal to CUSTOM"
  }

  validation {
    condition     = var.authorizer.authorization != "CUSTOM" || var.authorizer.lambda_arn != null
    error_message = "authorizer.lambda_arn can not be null when authorizer.authorization is equal to CUSTOM"
  }
}

