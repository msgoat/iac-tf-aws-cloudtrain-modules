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

variable "eks_cluster_name" {
  description = "Name of the target AWS EKS cluster"
  type        = string
}

variable "kubernetes_namespace_name" {
  description = "Name of the Kubernetes namespace which should host the AWS Load Balancer Controller"
  type = string
  default = "aws-system"
}

variable "helm_release_name" {
  description = "Name of the Helm release"
  type = string
  default = "aws-load-balancer-controller"
}

variable "helm_chart_version" {
  description = "Version of the Helm chart"
  type = string
  default = "1.5.2"
}

variable "replica_count" {
  description = "Number of replicas to run"
  type = number
  default = 2
}

variable "cert_manager_enabled" {
  description = "Controls if the AWS Load Controller relies on cert-manager to create the initial certificates"
  type = bool
  default = false
}