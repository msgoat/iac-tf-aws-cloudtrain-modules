locals {
  target_group_name_long = "tg-${var.region_name}-${var.solution_fqn}-${var.loadbalancer_name}-eks"
  target_group_name_short = "tg-${var.solution_fqn}-${var.loadbalancer_name}-eks"
  target_group_name = length(local.target_group_name_long) <= 32 ? local.target_group_name_long : local.target_group_name_short
}

resource aws_lb_target_group ingress_controller {
  name = local.target_group_name
  port = local.given_ingress_controller_config["traffic_port"]
  protocol = upper(local.given_ingress_controller_config["traffic_protocol"])
  vpc_id = data.aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    path = local.given_ingress_controller_config["health_probe_path"]
    port = local.given_ingress_controller_config["health_probe_port"]
    protocol = upper(local.given_ingress_controller_config["health_probe_protocol"])
    healthy_threshold = 3
    unhealthy_threshold = 5
    timeout = 3
    matcher = local.given_ingress_controller_config["health_probe_matcher"]
  }

  tags = merge({ Name = local.target_group_name }, local.module_common_tags)
}
