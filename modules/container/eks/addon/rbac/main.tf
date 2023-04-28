# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

# Unfortunately we have to initialize the kubectl provider inside a module
# because we would cause duplicate required_providers blocks otherwise
provider kubectl {
  host                   = data.aws_eks_cluster.given.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.given.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.given.token
  load_config_file       = false
}

locals {
  module_common_tags = merge(var.common_tags, { TerraformModuleName = "container/eks/rbac" })
}

data aws_caller_identity current {

}