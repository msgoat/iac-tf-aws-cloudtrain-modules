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

variable "eks_cluster_id" {
  description = "Unique identifier of the AWS EKS cluster to deploy to"
  type        = string
}

variable "kubernetes_namespace_templates" {
  description = "Templates for the Kubernetes namespaces to create"
  type = list(object({
    name                    = string
    labels                  = map(string)
    network_policy_enforced = bool
  }))
}
