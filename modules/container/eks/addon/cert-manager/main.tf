# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

locals {
  module_common_tags = merge(var.common_tags, { TerraformModuleName = "container/eks/addon/cert-manager" })
}

