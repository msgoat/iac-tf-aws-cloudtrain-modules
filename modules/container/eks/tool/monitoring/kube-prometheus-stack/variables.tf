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
  default = "kube-prometheus-stack"
}

variable grafana_ui_enabled {
  description = "Controls if the Grafana UI should be exposed; default: true"
  type = bool
  default = true
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

variable alert_manager_enabled {
  description = "Controls if the Prometheus Alert Manager should be deployed as well; default: false"
  type = bool
  default = false
}

variable alert_manager_ui_enabled {
  description = "Controls if the Prometheus Alert Manager UI should be exposed; default: false"
  type = bool
  default = false
}

variable alert_manager_host_name {
  description = "Fully qualified host name to be used to route traffic to the Prometheus Alert Manager UI; only required if alertmanager_ui_enabled is true"
  type = string
  default = ""
}

variable alert_manager_path {
  description = "Path to be used to route traffic to the Prometheus Alert Manager UI; only required if alertmanager_ui_enabled is true"
  type = string
  default = ""
}

variable kubernetes_ingress_class_name {
  description = "Name of the ingress class to be used to expose Grafana UI and Prometheus UI"
  type = string
  default = "nginx"
}

variable kubernetes_ingress_controller_type {
  description = "Type of the ingress controller to be used to expose Grafana UI and Prometheus UI; possible values are: `NGINX` or `TRAEFIK`"
  type = string
  default = "NGINX"
}

variable kubernetes_storage_class_name {
  description = "Name of the storage class to be used for all persistence volume claims"
  type = string
  default = "ebs-csi-gp3"
}

variable replica_count {
  description = "Number of replicas for all pods; default `2`"
  type = number
  default = 2
}

variable retention_days {
  description = "Number of days the telemetry data should be retained; default `7`"
  type = number
  default = 7
}

variable cert_manager_enabled {
  description = "Controls if all certificates required for this solution are provided via cert-manager; default: false"
  type = bool
  default = false
}

variable cert_manager_cluster_issuer_name {
  description = "Name of the ClusterIssuer used to issue certificates; required if `cert_manager_enabled` is true"
  type = string
  default = ""
}
