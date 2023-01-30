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
  description = "Fully qualified name of the AWS EKS cluster to deploy to"
  type = string
}

variable kubernetes_namespace_name {
  description = "Name of the Kubernetes namespace to deploy to"
  type = string
}

variable helm_release_name {
  description = "Name of the Helm release which deploys Kubernetes namespace to deploy to"
  type = string
  default = "elasticsearch"
}

variable elasticsearch_cluster_name {
  description = "Name of the ElasticSearch cluster"
  type = string
}

variable elasticsearch_storage_size {
  description = "Storage size allocated by each ElasticSearch cluster node in GB"
  type = number
}
