terraform {
  required_providers {
    aws = {
      version = "~> 4.56"
    }
    helm = {
      version = "~> 2.0"
    }
    kubernetes = {
      version = "~> 2.0"
    }
  }
}

locals {
  module_common_tags = var.common_tags
}
