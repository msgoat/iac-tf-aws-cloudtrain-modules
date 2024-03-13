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
  description = "Name of the target AWS EKS cluster"
  type = string
}

variable "hosted_zone_name" {
  description = "Name of a public hosted zone managed by Route53 supposed contain all public DNS records to route traffic to the AWS EKS cluster"
  type = string
}

variable "letsencrypt_account_name" {
  description = "Lets Encrypt Account name to be used to request certificates"
  type = string
}

variable "cert_manager_enabled" {
  description = "Controls if the AWS Load Controller relies on cert-manager to create the initial certificates"
  type = bool
}

variable eks_cluster_admin_role_names {
  description = "IAM role names to be added as system:masters to aws_auth config map"
  type = list(string)
}

variable "ensure_high_availability" {
  description = "Controls if a high availability of this service should be ensured by running at least two pods spread across AZs and nodes"
  type = bool
  default = true
}

variable addon_aws_auth_enabled {
  description = "Controls if addon `aws_auth` should be enabled; default `true`"
  type = bool
  default = true
}

variable addon_aws_ebs_csi_driver_enabled {
  description = "Controls if addon `aws_ebs_csi_driver_enabled` should be enabled; default `true`"
  type = bool
  default = true
}

variable addon_metrics_server_enabled {
  description = "Controls if addon `metrics_server` should be enabled; default `true`"
  type = bool
  default = true
}

variable addon_cluster_autoscaler_enabled {
  description = "Controls if addon `cluster_autoscaler` should be enabled; default `true`"
  type = bool
  default = true
}

variable addon_prometheus_enabled {
  description = "Controls if addon `prometheus` should be enabled; default `true`"
  type = bool
  default = true
}

variable addon_cert_manager_enabled {
  description = "Controls if addon `cert_manager_enabled` should be enabled; default `true`"
  type = bool
  default = true
}

variable addon_aws_load_balancer_controller_enabled {
  description = "Controls if addon `aws_load_balancer_controller` should be enabled; default `true`"
  type = bool
  default = true
}
