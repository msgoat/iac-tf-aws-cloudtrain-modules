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

variable "certificate_name" {
  description = "Logical name of the certificate."
  type        = string
}

variable "domain_name" {
  description = "DNS domain name the certificate should cover."
  type        = string
}

variable "alternative_domain_names" {
  description = "Alternative DNS domain names the certificate should cover (e.g. subdomain wildcards)."
  type        = list(string)
}
