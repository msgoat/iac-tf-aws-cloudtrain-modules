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
  module_common_tags = merge(var.common_tags, { TerraformModuleName = "storage/blob" })
}

data aws_region current {
  name = var.region_name
}
