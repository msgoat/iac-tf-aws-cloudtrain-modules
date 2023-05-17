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

variable ingress_type {
  description = "Type of ingress to install on the EKS cluster: possible values are `NGINX` or `TRAEFIK`; default: `NGINX`"
  type = string
  default = "NGINX"
}

variable eks_cluster_name {
  description = "Fully qualified name of the AWS EKS cluster to deploy to"
  type = string
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
