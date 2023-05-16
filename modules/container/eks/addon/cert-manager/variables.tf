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
  default = "cert-manager"
}

variable "kubernetes_namespace_owned" {
  description = "Controls if the given Kubernetes namespace will be created and destroyed by this module; default: true"
  type = bool
  default = true
}

variable "helm_release_name" {
  description = "Name of the Helm release"
  type = string
  default = "cert-manager"
}

variable "helm_chart_version" {
  description = "Version of the Helm chart"
  type = string
  default = "v1.11.1"
}

variable "replica_count" {
  description = "Number of replicas to run"
  type = number
  default = 2
}

variable "hosted_zone_name" {
  description = "Name of a public hosted zone managed by Route53 supposed contain all public DNS records to route traffic to the AWS EKS cluster"
  type = string
}

variable "letsencrypt_account_name" {
  description = "Lets Encrypt Account name to be used to request certificates"
  type = string
}
