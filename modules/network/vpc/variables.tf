variable "region_name" {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type        = string
}

variable "solution_name" {
  description = "The name of the solution that owns all AWS resources."
  type        = string
}

variable "solution_stage" {
  description = "The name of the current environment stage."
  type        = string
}

variable "solution_fqn" {
  description = "The fully qualified name of the solution (i.e. solution_name + solution_stage in most cases)."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be attached to all AWS resources."
  type        = map(string)
}

variable "network_name" {
  description = "The name suffix of the VPC."
  type        = string
}

variable "network_cidr" {
  description = "The CIDR range of the VPC."
  type        = string
}

variable "inbound_traffic_cidrs" {
  description = "The IP ranges in CIDR notation allowed to access any public resource within the network."
  type        = list(string)
}

variable "zones_to_span" {
  description = "The number of availability zones the VPC is supposed to span. (default: 0 == all availability zones)"
  type        = number
  default     = 0
}

variable "nat_strategy" {
  description = "NAT strategy to be applied to VPC. Possible values are: NAT_NONE (no NAT gateways), NAT_GATEWAY_SINGLE (one NAT gateway for all AZs in the VPC) or NAT_GATEWAY_AZ (one NAT gateway per AZ)"
  type        = string
}

variable "subnet_templates" {
  description = "Templates for subnets to be created in each availability zone the VPC is supposed to span"
  type = list(object({
    name   = string             # subnet template name
    accessibility = string      # accessibility of the subnet ("public" or "private")
    role          = string      # role or responsibility of the subnet; can be used to find all subnets with matching roles
    newbits       = number      # additional bits to extend the prefix of this subnet
    tags          = map(string) # Tags to be attached to the subnet
  }))
}
