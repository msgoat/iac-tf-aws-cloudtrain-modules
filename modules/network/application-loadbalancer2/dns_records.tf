module dns_records {
  for_each = toset(var.host_names)
  source = "../../dns/record-for-alb"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  alb_arn = aws_lb.loadbalancer.arn
  domain_name = each.value
  hosted_zone_name = var.domain_name
}