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
  module_common_tags           = merge(var.common_tags, { TerraformModuleName = "network/cloudfront" })
  create_origin_access_control = var.create_origin_access_control && length(keys(var.origin_access_control)) > 0
}
