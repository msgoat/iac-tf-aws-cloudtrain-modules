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

variable "loadbalancer_id" {
  description = "Unique identifier of the load balancer the given DNS name should point to."
  type        = string
}

variable "dns_name" {
  description = "DNS name which should point to the given balancer."
  type        = string
}

variable public_hosted_zone_id {
  description = "Unique identifier of a public DNS zone which should host the DNS records pointing to the given loadbalancer."
  type = string
}
