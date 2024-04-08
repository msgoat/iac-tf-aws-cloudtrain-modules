locals {
  domain_name_parts          = split(".", var.dns_zone_name)
  parent_domain_name_parts   = slice(local.domain_name_parts, 1, length(local.domain_name_parts))
  derived_parent_domain_name = join(".", local.parent_domain_name_parts)
}

data "aws_route53_zone" "derived_parent" {
  count = var.link_to_parent_domain && var.parent_dns_zone_id == "" ? 1 : 0
  name  = local.derived_parent_domain_name
}

data "aws_route53_zone" "given_parent" {
  count   = var.link_to_parent_domain && var.parent_dns_zone_id != "" ? 1 : 0
  zone_id = var.parent_dns_zone_id
}

resource "aws_route53_record" "parent_ns" {
  count   = var.link_to_parent_domain ? 1 : 0
  name    = local.domain_name_parts[0]
  type    = "NS"
  ttl     = 172800
  zone_id = var.parent_dns_zone_id != "" ? data.aws_route53_zone.given_parent[0].id : data.aws_route53_zone.derived_parent[0].id
  records = aws_route53_zone.this.name_servers
}