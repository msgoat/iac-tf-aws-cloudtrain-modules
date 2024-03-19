module dns_records {
  for_each = toset(var.host_names)
  source = "../../dns/record-for-alb"
  region_name = var.region_name
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  loadbalancer_id = aws_lb.this.arn
  dns_name = each.value
  public_hosted_zone_id = var.public_hosted_zone_id
}