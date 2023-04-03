locals {
  dns_name_parts = split(".", var.dns_name)
  derived_hosted_zone_name = join(".", slice(local.dns_name_parts, 1, length(local.dns_name_parts)))
  hosted_zone_name = var.hosted_zone_name == "" ? local.derived_hosted_zone_name : var.hosted_zone_name
}

data aws_route53_zone owner {
  name = local.hosted_zone_name
}