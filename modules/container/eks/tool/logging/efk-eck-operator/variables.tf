variable region_name {
  description = "The AWS region to deploy into."
  type = string
}

variable solution_name {
  description = "Name of this AWS solution"
  type = string
}

variable solution_stage {
  description = "Stage of this AWS solution"
  type = string
}

variable solution_fqn {
  description = "Fully qualified name of this AWS solution"
  type = string
}

variable common_tags {
  description = "Map of common tags to be attached to all managed AWS resources"
  type = map(string)
}

variable eks_cluster_name {
  description = "Name of an AWS EKS cluster"
  type = string
}

variable kubernetes_namespace_name {
  description = "Name of the Kubernetes namespace supposed to host the Cluster Logging Tool Stack"
  type = string
  default = "logging"
}

variable "kubernetes_namespace_owned" {
  description = "Controls if the given Kubernetes namespace will be created and destroyed by this module; default: true"
  type = bool
  default = true
}

variable kubernetes_ingress_class_name {
  description = "Name of the ingress class to be used to expose any tool UI included in this stack"
  type = string
}

variable kubernetes_ingress_controller_type {
  description = "Type of the ingress controller to be used to expose any tool UI in this stack; possible values are: `NGINX` or `TRAEFIK`"
  type = string
}

variable kubernetes_storage_class_name {
  description = "Name of the storage class to be used for all persistence volume claims"
  type = string
  default = "ebs-csi-gp3"
}

variable helm_release_name {
  description = "Name of the Helm release used to deploy the Cluster Logging Tool Stack"
  type = string
  default = "logging"
}

variable node_group_workload_class {
  description = "Class of the AKS node group this tool stack should be hosted on"
  type = string
  default = ""
}

variable topology_spread_strategy {
  description = "Strategy to use regarding distribution of pod replicas across node / availability zones; possible values are: none, soft and hard"
  type = string
  default = "hard"
}

variable kibana_host_name {
  description = "Fully qualified hostname used to route traffic to Kibana"
  type = string
}

variable kibana_path {
  description = "Path used to route traffic to Kibana; must start with a slash (`/`)"
  type = string
}

variable "cert_manager_enabled" {
  description = "Controls if cert-manager is installed and should be used for certificate management"
  type = bool
  default = false
}

variable "prometheus_operator_enabled" {
  description = "Controls if prometheus operator is installed and pod/service monitors should be enabled"
  type = bool
  default = false
}

variable "jaeger_enabled" {
  description = "Controls if jaeger is installed and support should be enabled"
  type = bool
  default = false
}

variable "jaeger_agent_host" {
  description = "Host name of the jaeger agent endpoint; required if `jaeger_enabled` is true"
  type = string
  default = ""
}

variable "jaeger_agent_port" {
  description = "Port number of the jaeger agent endpoint; required if `jaeger_enabled` is true"
  type = number
  default = 0
}

variable "fluentbit_helm_chart_version" {
  description = "Version number of the upstream FluentBit helm chart"
  type = string
  default = "0.39.0"
}

variable "elasticsearch_version" {
  description = "Version of elastic search to deploy"
  type = string
  default = "8.10.4"
}

variable "elasticsearch_storage_class" {
  description = "Kubernetes storage class to use for elastic search's persistent volume claims"
  type = string
  default = "ebs-csi-gp3"
}

variable "elasticsearch_storage_size" {
  description = "Kubernetes storage size in GB to use for elastic search's persistent volume claims"
  type = number
  default = 32
}

variable "kibana_version" {
  description = "Version of Kibana search to deploy; matches the Elasticsearch version by default"
  type = string
  default = ""
}

variable "ensure_high_availability" {
  description = "Controls if a high availability of this service should be ensured by running at least two pods spread across AZs and nodes"
  type = bool
  default = true
}
