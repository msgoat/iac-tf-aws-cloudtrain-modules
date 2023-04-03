resource aws_route53_record this {
  name = var.dns_name
  zone_id = data.aws_route53_zone.owner.id
  type = "A"
  alias {
    evaluate_target_health = true
    name                   = data.aws_alb.given.dns_name
    zone_id                = data.aws_alb.given.zone_id
  }

}