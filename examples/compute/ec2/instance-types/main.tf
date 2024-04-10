terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "ec2_instance_types" {
  source = "../../../..//modules/compute/ec2/instance-types"
  region_name = "eu-west-1"
  cores = 4
  memory = 16
  cpu_architecture = "arm64"
}