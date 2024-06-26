# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------
# Main entrypoint of this Terraform module.
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Local values used in this module
locals {
  module_common_tags = merge(var.common_tags, { TerraformModuleName = "network/vpc2" })
}

data "aws_region" "current" {

}

data "aws_availability_zones" "zones" {
  state = "available"
}
