# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    kubernetes = {
      version = "~> 2.0"
    }
    helm = {
      version = "~> 2.0"
    }
    random = {
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region_name
}

locals {
  module_common_tags = var.common_tags
}

