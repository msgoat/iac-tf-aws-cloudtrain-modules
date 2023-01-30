# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    helm = {
      version = "~> 2.0"
    }
  }
}

provider aws {
  region = var.region_name
}

data aws_region current {
  name = var.region_name
}

data aws_availability_zones available_zones {
  state = "available"
}

data aws_caller_identity current {

}

locals {
  module_common_tags = var.common_tags
}

