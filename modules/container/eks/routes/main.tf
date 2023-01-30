# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  route_template_keys = [ for r in var.routes : r.name ]
  route_templates = zipmap(local.route_template_keys, var.routes)
}