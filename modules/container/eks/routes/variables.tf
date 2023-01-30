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

variable loadbalancer_id {
  description = "Unique identifier of the Application Load Balancer to add the new routes to"
  type = string
}

variable loadbalancer_target_group_id {
  description = "Unique identifier of the Application Load Balancer to forward to"
  type = string
}

variable public_dns_zone_name {
  description = "Public hosted zone to add the new DNS records to"
  type = string
  default = ""
}

variable routes {
  description = "List of routes to be added to the given Application Load Balancer"
  type = list(object({
    name = string
    host_name = string
    path = string
  }))
}

