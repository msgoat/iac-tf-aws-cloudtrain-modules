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
  description = "Controls if Traefik is the default ingress controller on this cluster; default: true"
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
  default = "ingress-traefik"
}

variable helm_release_name {
  description = "Name of the Helm release which deploys Traefik"
  type = string
  default = "traefik"
}

variable helm_chart_version {
  description = "Version of the Helm chart which deploys Traefik"
  type = string
  default = "traefik"
}

variable replica_count {
  description = "Number of replicas running Traefik"
  type = number
  default = 2
}

variable use_aws_load_balancer_controller {
  description = "Controls if Traefik should use the AWS Load Balancer Controller to expose its endpoints"
  type = bool
  default = false
}

variable aws_load_balancer_strategy {
  description = "Strategy to use when exposing Traefik's endpoints; possible values are `SERVICE_VIA_NLB` or `INGRESS_VIA_ALB`"
  type = string
  default = "INGRESS_VIA_ALB"
}

variable tls_certificate_arn {
  description = "ARN of a TLS certificate managed by AWS Certificate Manager; required if `use_aws_load_balancer_controller` is true"
  type = string
  default = ""
}
