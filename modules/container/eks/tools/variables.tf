# variables.tf
# ---------------------------------------------------------------------------
# Defines all input variable for this demo.
# ---------------------------------------------------------------------------

variable "region_name" {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type        = string
}

variable "solution_name" {
  description = "The name of the AWS solution that owns all AWS resources."
  type        = string
}

variable "solution_stage" {
  description = "The name of the current AWS solution stage."
  type        = string
}

variable "solution_fqn" {
  description = "The fully qualified name of the current AWS solution."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be attached to all AWS resources"
  type        = map(string)
}

variable "eks_cluster_id" {
  description = "Unique identifier of the target AWS EKS cluster"
  type        = string
}

variable "kubernetes_ingress_class_name" {
  description = "Name of the ingress class to be used to expose any tool"
  type        = string
}

variable "kubernetes_ingress_controller_type" {
  description = "Type of the ingress controller to be used to expose Grafana UI and Prometheus UI; possible values are: `NGINX` or `TRAEFIK`"
  type        = string
}

variable "kubernetes_storage_class_name" {
  description = "Name of the storage class to be used for all persistence volume claims"
  type        = string
  default     = "ebs-csi-gp3" # @TODO: pass from add-on aws-ebs-csi-driver
}

variable "prometheus_operator_enabled" {
  description = "Controls if prometheus operator is installed and pod/service monitors should be enabled"
  type        = bool
  default     = true # @TODO: remove default
}

variable "prometheus_storage_size" {
  description = "Size of Prometheus Server's persistent volume claim in GB; default `8`"
  type        = number
  default     = 8 # @TODO: remove default
}

variable "prometheus_retention_days" {
  description = "Number of days the telemetry data should be retained; default `7`"
  type        = number
  default     = 7 # @TODO: remove default
}

variable "prometheus_ui_enabled" {
  description = "Controls if the Prometheus UI should be exposed; default: false"
  type        = bool
  default     = false
}

variable "prometheus_host_name" {
  description = "Fully qualified host name to be used to route traffic to the Prometheus UI; only required if prometheus_ui_enabled is true"
  type        = string
}

variable "prometheus_path" {
  description = "Path to be used to route traffic to the Prometheus UI; only required if prometheus_ui_enabled is true"
  type        = string
}

variable "alert_manager_enabled" {
  description = "Controls if the Prometheus Alert Manager should be deployed as well; default: false"
  type        = bool
  default     = false
}

variable "alert_manager_storage_size" {
  description = "Size of Prometheus Alert Manager's persistent volume claim in GB; default `8`"
  type        = number
  default     = 8
}

variable "alert_manager_ui_enabled" {
  description = "Controls if the Prometheus Alert Manager UI should be exposed; default: false"
  type        = bool
  default     = false
}

variable "alert_manager_host_name" {
  description = "Fully qualified host name to be used to route traffic to the Prometheus Alert Manager UI; only required if alertmanager_ui_enabled is true"
  type        = string
  default     = ""
}

variable "alert_manager_path" {
  description = "Path to be used to route traffic to the Prometheus Alert Manager UI; only required if alertmanager_ui_enabled is true"
  type        = string
  default     = ""
}

variable "grafana_enabled" {
  description = "Controls if the Grafana should be installed; default: true"
  type        = bool
  default     = true
}

variable "grafana_ui_enabled" {
  description = "Controls if the Grafana UI should be exposed; default: true"
  type        = bool
  default     = true
}

variable "grafana_storage_size" {
  description = "Size of Grafana's persistent volume claim in GB; default `8`"
  type        = number
  default     = 8 # @TODO: remove default
}

variable "grafana_host_name" {
  description = "Fully qualified host name to be used to route traffic to the Grafana UI"
  type        = string
}

variable "grafana_path" {
  description = "Path to be used to route traffic to the Grafana UI"
  type        = string
}

variable "cert_manager_enabled" {
  description = "Controls if cert-manager is installed and should be used for certificate management"
  type        = bool
}

variable "cert_manager_cluster_issuer_name" {
  description = "Name of the ClusterIssuer used to issue certificates; required if `cert_manager_enabled` is true"
  type        = string
  default     = ""
}

variable "kibana_host_name" {
  description = "Fully qualified hostname used to route traffic to Kibana"
  type        = string
}

variable "kibana_path" {
  description = "Path used to route traffic to Kibana; must start with a slash (`/`)"
  type        = string
}

variable "jaeger_enabled" {
  description = "Controls if jaeger is installed and support should be enabled"
  type        = bool
  default     = false
}

variable "jaeger_host_name" {
  description = "Fully qualified hostname used to route traffic to the Jaeger UI"
  type        = string
}

variable "jaeger_path" {
  description = "Path used to route traffic to the Jaeger UI"
  type        = string
}

variable "jaeger_agent_host" {
  description = "Host name of the jaeger agent endpoint; required if `jaeger_enabled` is true"
  type        = string
  default     = ""
}

variable "jaeger_agent_port" {
  description = "Port number of the jaeger agent endpoint; required if `jaeger_enabled` is true"
  type        = number
  default     = 0
}

variable "ensure_high_availability" {
  description = "Controls if a high availability of this service should be ensured by running at least two pods spread across AZs and nodes"
  type        = bool
  default     = true
}

variable "node_group_workload_class" {
  description = "Workload class which refers to a specific node group this addon should be hosted on; default unspecified (i.e. workload is running on default node group)"
  type        = string
  default     = ""
}
