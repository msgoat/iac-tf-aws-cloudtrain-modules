resource "aws_route53_zone" "this" {
  name = var.dns_zone_name
  tags = local.module_common_tags
}