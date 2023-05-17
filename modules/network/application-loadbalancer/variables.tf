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

variable loadbalancer_name {
  description = "Logical name of the newly created Application Load Balancer"
  type = string
}

variable loadbalancer_subnet_ids {
  description = "Unique identifiers of all subnets inside the VPC supposed to host the Application Load Balancer"
  type = list(string)
}

variable target_group_subnet_ids {
  description = "Unique identifiers of all subnets inside the VPC supposed to host target groups"
  type = list(string)
}

variable domain_name {
  description = "DNS domain names of hosts whose traffic should be routed through the Application Load Balancer"
  type = string
}

variable target_group {
  description = "Configuration of the default target group"
  type = object({
    name = string
    port = number
    protocol = string
  })
  default = {
    name = "default"
    port = 32000
    protocol = "HTTP"
  }
}

variable target_group_health_check {
  description = "Configuration of the default target group health check"
  type = object({
    path = string
    port = number
    protocol = string
    healthy_threshold = number
    unhealthy_threshold = number
    timeout = number
  })
  default = {
    path = "/health"
    port = 32000
    protocol = "HTTP"
    healthy_threshold = 5
    unhealthy_threshold = 5
    timeout = 2
  }
}

variable inbound_traffic_cidrs {
  description = "IP address ranges which are allowed to send inbound traffic to the Application Loadbalancer"
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable ssl_security_policy {
  description = "Security policy used for the HTTPS listener"
  type = string
  default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable cm_certificate_arn {
  description = "ARN of an existing Azure Certificate Manager TLS certificate to use for https"
  type = string
}

variable loadbalancer_security_group_ids {
  description = "Unique identifiers of security groups which allow an external loadbalancer to talk to the ingress controller via node ports"
  type = list(string)
  default = []
}