# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

locals {
  module_common_tags = merge(var.common_tags, { TerraformModuleName = "container/ingress/default" })
}

