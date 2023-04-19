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
  default = "4.6.0"
}

variable replica_count {
  description = "Number of replicas running NGINX"
  type = number
  default = 2
}

variable load_balancer_strategy {
  description = "Strategy to use when exposing NGINX's endpoints; possible values are `SERVICE_VIA_NODE_PORT`, `SERVICE_VIA_NLB` or `INGRESS_VIA_ALB`"
  type = string
  default = "SERVICE_VIA_NODE_PORT"
}

variable tls_certificate_arn {
  description = "ARN of a TLS certificate managed by AWS Certificate Manager; required if `load_balancer_strategy` is either `SERVICE_VIA_NLB` or `INGRESS_VIA_ALB`"
  type = string
  default = ""
}

variable host_name {
  description = "Host name of requests supposed to be forwarded to the ingress controller; required if `load_balancer_strategy` is `INGRESS_VIA_ALB`"
  type = string
  default = ""
}

variable "cert_manager_enabled" {
  description = "Controls if the AWS Load Controller relies on cert-manager to create the initial certificates"
  type = bool
  default = false
}