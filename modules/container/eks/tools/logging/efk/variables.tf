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

variable addon_enabled {
  description = "Controls if this addon is actually activated"
  type = bool
  default = true
}

variable eks_cluster_name {
  description = "Name of an AWS EKS cluster"
  type = string
}

variable kubernetes_namespace_name {
  description = "Name of the Kubernetes namespace to deploy to"
  type = string
  default = "logging"
}

variable helm_release_name {
  description = "Name of the Helm release which represents a deployment of this stack"
  type = string
  default = "logging"
}

variable kibana_host_name {
  description = "Fully qualified hostname used to route traffic to Kibana"
  type = string
}

variable kibana_path {
  description = "Path used to route traffic to Kibana"
  type = string
}
