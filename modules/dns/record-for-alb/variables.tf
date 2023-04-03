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

variable "alb_arn" {
  description = "ARN of an existing AWS application load balancer."
  type        = string
}

variable "dns_name" {
  description = "DNS name of the given load balancer."
  type        = string
}

variable "hosted_zone_name" {
  description = "Name of the hosted zone supposed to own the new DNS record; if empty the hosted zone is derived from the given `dns_name`."
  type        = string
  default     = ""
}

