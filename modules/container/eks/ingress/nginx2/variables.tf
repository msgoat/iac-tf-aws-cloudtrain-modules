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

variable default_ingress_class {
  description = "Controls if NGinX is the default ingress controller on this cluster; default: false"
  type = bool
  default = false
}

variable eks_cluster_name {
  description = "Fully qualified name of the AWS EKS cluster to deploy to"
  type = string
}

variable kubernetes_namespace_name {
  description = "Name of the Kubernetes namespace to deploy to"
  type = string
  default = "ingress-nginx"
}

variable helm_release_name {
  description = "Name of the Helm release which deploys NGINX"
  type = string
  default = "ingress-nginx"
}

variable helm_chart_version {
  description = "Version of the Helm chart which deploys NGINX"
  type = string
  default = "4.8.3"
}

variable replica_count {
  description = "Number of replicas running NGINX"
  type = number
  default = 2
}

variable load_balancer_strategy {
  description = "Strategy to use when exposing NGINX's endpoints; possible values are `SERVICE_VIA_NODE_PORT`, `SERVICE_VIA_NLB`, `SERVICE_VIA_TARGET_GROUP_BINDING` or `INGRESS_VIA_ALB`"
  type = string
  default = "SERVICE_VIA_NODE_PORT"
}

variable tls_certificate_arn {
  description = "ARN of a TLS certificate managed by AWS Certificate Manager; required if `load_balancer_strategy` is either `SERVICE_VIA_NLB` or `INGRESS_VIA_ALB`"
  type = string
  default = ""
}

variable loadbalancer_subnet_ids {
  description = "Unique identifiers of all subnets inside the VPC supposed to host the Application Load Balancer"
  type = list(string)
  default = []
}

variable target_group_subnet_ids {
  description = "Unique identifiers of all subnets inside the VPC supposed to host target groups"
  type = list(string)
  default = []
}

variable target_group_arn {
  description = "ARN of an existing target group attached to a previously created AWS load balancer; required if `load_balancer_strategy` is `SERVICE_VIA_TARGET_GROUP_BINDING`"
  type = string
  default = ""
}

variable host_name {
  description = "Host name of requests supposed to be forwarded to the ingress controller; required if `load_balancer_strategy` is `INGRESS_VIA_ALB`"
  type = string
  default = ""
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

variable "ensure_high_availability" {
  description = "Controls if a high availability of this service should be ensured by running at least two pods spread across AZs and nodes"
  type = bool
  default = true
}

variable node_group_workload_class {
  description = "Class of the EKS node group the Elastic Cloud Operator for Kubernetes should be hosted on"
  type = string
  default = ""
}
