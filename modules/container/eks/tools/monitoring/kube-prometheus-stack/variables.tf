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

variable helm_release_name {
  description = "Name of the Helm release which represents a deployment of this stack"
  type = string
  default = "monitoring-stack"
}

variable grafana_host_name {
  description = "Fully qualified host name to be used to route traffic to the Grafana UI"
  type = string
}

variable grafana_path {
  description = "Path to be used to route traffic to the Grafana UI"
  type = string
}

variable prometheus_ui_enabled {
  description = "Controls if the Prometheus UI should be exposed; default: false"
  type = bool
  default = false
}

variable prometheus_host_name {
  description = "Fully qualified host name to be used to route traffic to the Prometheus UI; only required if prometheus_ui_enabled is true"
  type = string
  default = ""
}

variable prometheus_path {
  description = "Path to be used to route traffic to the Prometheus UI; only required if prometheus_ui_enabled is true"
  type = string
  default = ""
}
