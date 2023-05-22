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
  description = "Fully qualified name of the AWS EKS cluster to deploy to"
  type = string
}

variable kubernetes_namespace_name {
  description = "Name of the Kubernetes namespace to deploy to"
  type = string
  default = "tracing"
}

variable helm_release_name {
  description = "Name of the Helm release which represents a deployment of this stack"
  type = string
  default = "jaeger"
}

variable jaeger_host_name {
  description = "Fully qualified hostname used to route traffic to the Jaeger UI"
  type = string
}

variable jaeger_path {
  description = "Path used to route traffic to the Jaeger UI"
  type = string
}

variable node_group_workload_class {
  description = "Class of the AKS node group this tool stack should be hosted on"
  type = string
  default = ""
}

variable ingress_class_name {
  description = "Ingress class name"
  type = string
  default = "nginx"
}

variable ingress_controller_type {
  description = "Ingress controller type; possible values are `NGINX` or `TRAEFIK`"
  type = string
  default = "NGINX"
}

variable elasticsearch_strategy {
  description = "Controls which type of Elasticsearch backend will be used as a datastore; possible values are: `ES_INTERNAL`, `ES_OPENSEARCH`, `ES_ECK_OPERATOR`, default: `ES_INTERNAL`"
  type = string
  default = "ES_INTERNAL"
}
