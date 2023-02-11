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

# Local values used in this module
locals {
  module_common_tags = merge(var.common_tags,
  {
    ManagedBy = "Terraform"
    TerraformModuleName = "terraform/remote-state"
  })
  s3_bucket_name = "s3-${var.region_name}-${var.solution_fqn}-${var.backend_name}"
  dynamodb_table_name = "dyn-${var.region_name}-${var.solution_fqn}-${var.backend_name}"
}

data aws_region current {
  name = var.region_name
}

locals {
  terraform_backend_file = templatefile("${path.module}/resources/terraform_backend.template.tf", {
    tf_s3_bucket_name = local.s3_bucket_name
    tf_dynamodb_table_name = local.dynamodb_table_name
    tf_state_key_name = "${var.solution_name}/${var.solution_stage}/terraform.tfstate"
  })
  terragrunt_remote_state_block = templatefile("${path.module}/resources/terragrunt_remote_state_block.template.hcl", {
    tf_s3_bucket_name = local.s3_bucket_name
    tf_dynamodb_table_name = local.dynamodb_table_name
  })
}