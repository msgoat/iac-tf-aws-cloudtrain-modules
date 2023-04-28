# variables.tf
# ---------------------------------------------------------------------------
# Defines all input variable for this demo.
# ---------------------------------------------------------------------------

variable "region_name" {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type        = string
}

variable "solution_name" {
  description = "The name of the AWS solution that owns all AWS resources."
  type        = string
}

variable "solution_stage" {
  description = "The name of the current AWS solution stage."
  type        = string
}

variable "solution_fqn" {
  description = "The fully qualified name of the current AWS solution."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be attached to all AWS resources"
  type        = map(string)
}

variable "kubernetes_namespace_name" {
  description = "Name of the Kubernetes namespace which should host the AWS Load Balancer Controller"
  type = string
}

variable "helm_release_name" {
  description = "Name of the Helm release"
  type = string
  default = "ingress-certificates"
}

variable "organization_names" {
  description = "Names of organizations owing the TLS certificates"
  type = list(string)
}

variable "domain_names" {
  description = "Domain names the TLS certificates should cover (like `example.com`, `www.example.com`)"
  type = list(string)
}

variable "wildcard_certificate_enabled" {
  description = "Controls if a wildcard certificate for the given domain_names should be created as well"
  type = bool
  default = false # wildcard certificates are considered as bad practice
}

variable "letsencrypt_environment" {
  description = "Controls to which LetsEncrypt environment the TLS request is sent; possible values are `staging` or `prod`"
  type = string
  default = "staging"
}