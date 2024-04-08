# ----------------------------------------------------------------------------
# main.tf
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
  module_common_tags = merge(var.common_tags,
    {
      ManagedBy           = "Terraform"
      TerraformModuleName = "terraform/remote-state"
  })
  s3_bucket_name      = "s3-${var.region_name}-${var.solution_fqn}-${var.backend_name}"
  dynamodb_table_name = "dyn-${var.region_name}-${var.solution_fqn}-${var.backend_name}"
}

data "aws_region" "current" {
  name = var.region_name
}

data "aws_caller_identity" "current" {

}

locals {
  terraform_backend_file = <<EOT
terraform {
  backend "s3" {
    bucket = "${local.s3_bucket_name}"
    dynamodb_table = "${local.dynamodb_table_name}"
    key = "${var.solution_name}/${var.solution_stage}/terraform.tfstate"
  }
}
EOT
  terraform_backend_config = <<EOT
region = "${var.region_name}"
bucket = "${local.s3_bucket_name}"
dynamodb_table = "${local.dynamodb_table_name}"
EOT
  terragrunt_remote_state_block = <<EOT
remote_state {
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "${local.s3_bucket_name}"
    dynamodb_table = "${local.dynamodb_table_name}"
    key = "$${path_relative_to_include()}/terraform.tfstate"
  }
}
EOT
}