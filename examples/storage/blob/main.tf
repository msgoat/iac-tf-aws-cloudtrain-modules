terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider aws {
  region = var.region_name
}

module "blob" {
  source = "../../..//modules/storage/blob"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = var.common_tags
  bucket_name = var.bucket_name
  deny_unencrypted_uploads = var.deny_unencrypted_uploads
}

/* Uncomment this to troubleshoot JSON issues
output policy_json {
  value = module.blob.policy_json
}
*/