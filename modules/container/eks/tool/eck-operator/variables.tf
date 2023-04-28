variable region_name {
  description = "The Azure region to deploy into."
  type = string
}

variable region_code {
  description = "The code of Azure region to deploy into (supposed to be a meaningful abbreviation of region_name)"
  type = string
}

variable common_tags {
  description = "Map of common tags to be attached to all managed Azure resources"
  type = map(string)
}

variable solution_name {
  description = "Name of this Azure solution"
  type = string
}

variable solution_stage {
  description = "Stage of this Azure solution"
  type = string
}

variable solution_fqn {
  description = "Fully qualified name of this Azure solution"
  type = string
}

variable resource_group_name {
  description = "The name of the resource group supposed to own all allocated resources"
  type = string
}

variable resource_group_location {
  description = "The location of the resource group supposed to own all allocated resources"
  type = string
}

variable eks_cluster_id {
  description = "Unique identifier of the EKS cluster"
  type = string
}

variable kubernetes_namespace_name {
  description = "Name of the Kubernetes namespace supposed to host the Elastic Cloud Operator for Kubernetes"
  type = string
  default = "elastic-system"
}

variable helm_chart_version {
  description = "Version of the Helm chart to use to deploy the Elastic Cloud Operator for Kubernetes"
  type = string
  default = "2.6.1"
}

variable helm_release_name {
  description = "Name of the Helm release used to deploy the Elastic Cloud Operator for Kubernetes"
  type = string
  default = "eckop"
}

variable node_group_workload_class {
  description = "Class of the EKS node group the Elastic Cloud Operator for Kubernetes should be hosted on"
  type = string
  default = ""
}
