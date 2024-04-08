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

variable "dns_zone_name" {
  description = "Name of a DNS zone the newly created Route53 hosted zone should manage."
  type        = string
}

variable "link_to_parent_domain" {
  description = "Controls if the newly created Route53 hosted zone should be linked to a parent hosted zone; default: true"
  type        = bool
  default     = true
}

variable "parent_dns_zone_id" {
  description = "Optional unique identifier name of a DNS domain/Route53 hosted zone the newly created hosted zone should be linked to; if missing, the name of the parent domain is derived from the given `domain_name`"
  type        = string
  default     = ""
}
