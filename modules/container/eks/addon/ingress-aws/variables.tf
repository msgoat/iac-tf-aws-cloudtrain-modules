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
  description = "Name of the Kubernetes namespace which should host the AWS Load Balancer Controller"
  type        = string
  default     = "ingress-aws"
}

variable "kubernetes_namespace_owned" {
  description = "Controls if the given Kubernetes namespace will be created and destroyed by this module; default: true"
  type        = bool
  default     = true
}

variable "kubernetes_ingress_class_name" {
  description = "Name of the Kubernetes ingress class to be assigned to this ingress controller"
  type        = string
  default     = "aws"
}

variable "kubernetes_default_ingress_class" {
  description = "Controls if this ingress controller is the default ingress controller on this cluster; default: false"
  type        = bool
  default     = false
}

variable "helm_release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "helm_chart_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = "1.7.1"
}

variable "replica_count" {
  description = "Number of replicas to run"
  type        = number
  default     = 2
}

variable "cert_manager_enabled" {
  description = "Controls if the AWS Load Controller relies on cert-manager to create the initial certificates"
  type        = bool
  default     = false
}

variable "cert_manager_cluster_issuer_name" {
  description = "Name of the cert-manager cluster issuers used to request certificates; only required if `cert_manager_enabled` is true"
  type        = string
  default     = ""
}

variable "ensure_high_availability" {
  description = "Controls if a high availability of this service should be ensured by running at least two pods spread across AZs and nodes"
  type        = bool
  default     = true
}

variable "prometheus_operator_enabled" {
  description = "Controls if a ServiceMonitor must be used to expose metric data"
  type        = bool
}
