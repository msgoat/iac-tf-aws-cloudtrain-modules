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

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "kubernetes_cluster_name" {
  description = "Logical name of the AWS EKS cluster"
  type        = string
}

variable "kubernetes_api_access_cidrs" {
  description = "CIDR blocks defining source API ranges allowed to access the Kubernetes API"
  type        = list(string)
}

variable "vpc_id" {
  description = "Unique identifier of the VPC supposed to host the EKS cluster"
  type        = string
}

variable "zones_to_span" {
  description = "Names of availability zones the AWS EKS cluster is supposed to span"
  type        = list(string)
}

variable "node_group_subnet_ids" {
  description = "Unique identifiers of all subnets to host EKS cluster nodes assuming one subnet per AZ to span"
  type        = list(string)
}

variable "node_group_strategy" {
  description = "Controls how node groups are spanning the given subnets: `SINGLE_MULTI_AZ` one nodegroup for all AZs spans all subnets, `MULTI_SINGLE_AZ` multiple dedicated nodegroups per AZ span only one subnet"
  type        = string
  default     = "SINGLE_MULTI_AZ"
}

variable "node_group_templates" {
  description = "Templates for node groups attached to the AWS EKS cluster, will be replicated for each spanned zone"
  type = list(object({
    enabled            = optional(bool, true)      # controls if this node group gets actually created
    managed            = optional(bool, true)      # controls if this node group is managed or unmanaged
    name               = string                    # logical name of this nodegroup
    kubernetes_version = optional(string, null)    # Kubernetes version of the blue node group; will default to kubernetes_version, if not specified but may differ from kubernetes_version during cluster upgrades
    min_size           = number                    # minimum size of this node group
    max_size           = number                    # maximum size of this node group
    desired_size       = optional(number, 0)       # desired size of this node group; will default to min_size if set to 0
    disk_size          = number                    # size of attached EBS volume in GB
    capacity_type      = string                    # defines the purchasing option for the EC2 instances in all node groups
    instance_types     = list(string)              # EC2 instance types which should be used for the AWS EKS worker node groups ordered descending by preference
    labels             = optional(map(string), {}) # Kubernetes labels to be attached to each worker node
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])                                    # Kubernetes taints to be attached to each worker node
    image_type = optional(string, "AL2_x86_64") # Type of OS images to be used for EC2 instances; possible values are: AL2_x86_64 | AL2_x86_64_GPU | AL2_ARM_64 | CUSTOM | BOTTLEROCKET_ARM_64 | BOTTLEROCKET_x86_64 | BOTTLEROCKET_ARM_64_NVIDIA | BOTTLEROCKET_x86_64_NVIDIA; default is "AL2_x86_64"
  }))
}

variable "private_endpoint_enabled" {
  description = "controls if the communication between worker nodes and control plane nodes should use private connections"
  type        = bool
  default     = true
}

variable "loadbalancer_security_group_enabled" {
  description = "controls if the security groups controlling traffic between an application loadbalancer and the worker nodes should be created"
  type        = bool
  default     = false
}

variable "access_config_authentication_mode" {
  description = "controls the authentication mode when accessing Kubernetes objects on a Kubernetes cluster; possible values are: CONFIG_MAP | API | API_AND_CONFIG_MAP; default: API_AND_CONFIG_MAP"
  type        = string
  default     = "API_AND_CONFIG_MAP" # @TODO: consider switching to API as default!
}