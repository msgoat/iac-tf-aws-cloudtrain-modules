# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      version = "~> 3.0"
    }
  }
}

# Local values used in this module
locals {
  module_common_tags = var.common_tags
}

data aws_region current {
  name = var.region_name
}

data aws_availability_zones available_zones {
  state = "available"
}

data "aws_caller_identity" "current" {

}
