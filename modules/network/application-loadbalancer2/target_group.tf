locals {
  target_group_name_long = "tg-${var.region_name}-${var.solution_fqn}-${var.target_group.name}"
  target_group_name_short = "tg-${var.solution_fqn}-${var.target_group.name}"
  target_group_name = length(local.target_group_name_long) <= 32 ? local.target_group_name_long : local.target_group_name_short
}

resource aws_lb_target_group ingress {
  name = local.target_group_name
  port = var.target_group.port
  protocol = var.target_group.protocol
  vpc_id = data.aws_vpc.vpc.id

  health_check {
    path = var.target_group_health_check.path
    port = var.target_group_health_check.port
    protocol = var.target_group.protocol
    healthy_threshold = var.target_group_health_check.healthy_threshold
    unhealthy_threshold = var.target_group_health_check.unhealthy_threshold
    timeout = var.target_group_health_check.timeout
  }

  tags = merge({ Name = local.target_group_name }, local.module_common_tags)
}
