locals {
  vpc_name = "vpc-${var.region_name}-${var.solution_fqn}-${lower(var.network_name)}"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.network_cidr
  # all public available instances should have DNS names
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge({ "Name" = local.vpc_name }, local.module_common_tags)
}

