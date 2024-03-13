# variables.tf
# ---------------------------------------------------------------------------
# Defines all input variable for this demo.
# ---------------------------------------------------------------------------

variable region_name {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type = string
}

variable solution_name {
  description = "The name of the AWS solution that owns all AWS resources."
  type = string
}

variable solution_stage {
  description = "The name of the current AWS solution stage."
  type = string
}

variable solution_fqn {
  description = "The fully qualified name of the current AWS solution."
  type = string
}

variable common_tags {
  description = "Common tags to be attached to all AWS resources"
  type = map(string)
}

variable eks_cluster_name {
  description = "Name of an AWS EKS cluster"
  type = string
}

variable kubernetes_namespace_name {
  description = "Name of the Kubernetes namespace to deploy to"
  type = string
  default = "monitoring"
}

variable "kubernetes_namespace_owned" {
  description = "Controls if the given Kubernetes namespace will be created and destroyed by this module; default: true"
  type = bool
  default = true
}

variable helm_release_name {
  description = "Name of the Helm release which represents a deployment of this stack"
  type = string
  default = "prometheus"
}

variable helm_chart_version {
  description = "Version of the upstream Helm chart"
  type = string
  default = "57.0.2"
}

variable prometheus_storage_size {
  description = "Size of Prometheus Server's persistent volume claim in GB; default `8`"
  type = number
  default = 8
}

variable alert_manager_enabled {
  description = "Controls if the Prometheus Alert Manager should be deployed as well; default: false"
  type = bool
  default = false
}

variable alert_manager_storage_size {
  description = "Size of Prometheus Alert Manager's persistent volume claim in GB; default `8`"
  type = number
  default = 8
}

variable kubernetes_storage_class_name {
  description = "Name of the storage class to be used for all persistence volume claims"
  type = string
  default = "ebs-csi-gp3"
}

variable replica_count {
  description = "Number of replicas for all pods; default `2`"
  type = number
  default = 2
}

variable retention_days {
  description = "Number of days the telemetry data should be retained; default `7`"
  type = number
  default = 7
}

variable cert_manager_enabled {
  description = "Controls if all certificates required for this solution are provided via cert-manager; default: false"
  type = bool
  default = false
}

variable cert_manager_cluster_issuer_name {
  description = "Name of the ClusterIssuer used to issue certificates; required if `cert_manager_enabled` is true"
  type = string
  default = ""
}

variable "ensure_high_availability" {
  description = "Controls if a high availability of this service should be ensured by running at least two pods spread across AZs and nodes"
  type = bool
  default = true
}