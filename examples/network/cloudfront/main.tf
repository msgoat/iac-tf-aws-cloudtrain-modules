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

module "host-bucket" {
  source                   = "../../..//modules/storage/blob"
  region_name              = var.region_name
  solution_name            = var.solution_name
  solution_stage           = var.solution_stage
  solution_fqn             = var.solution_fqn
  common_tags              = var.common_tags
  bucket_name              = var.bucket_name
  deny_unencrypted_uploads = var.deny_unencrypted_uploads
}

resource "aws_cloudfront_origin_access_identity" "cloudfront_oai" {
}

module "cloudfront" {
  source = "../../..//modules/network/cloudfront"

  region_name    = var.region_name
  solution_fqn   = var.solution_fqn
  solution_name  = var.solution_name
  solution_stage = var.solution_stage
  common_tags    = var.common_tags

  origin = {
    domain_name            = module.host-bucket.s3_bucket_arn
    origin_id              = module.host-bucket.s3_bucket_id
    origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_oai.cloudfront_access_identity_path
  }
}
