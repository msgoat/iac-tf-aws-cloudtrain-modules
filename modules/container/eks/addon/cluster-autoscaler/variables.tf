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
  description = "Unique identifier of the target AWS EKS cluster"
  type        = string
}

variable "kubernetes_namespace_name" {
  description = "Name of the Kubernetes namespace which should host the metrics-server"
  type        = string
  default     = "aws-system"
}

variable "helm_release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "aws-cluster-autoscaler"
}

variable "helm_chart_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = "9.29.4"
}

variable "ensure_high_availability" {
  description = "Controls if a high availability of this service should be ensured by running at least two pods spread across AZs and nodes"
  type        = bool
  default     = true
}