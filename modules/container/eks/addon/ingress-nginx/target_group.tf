locals {
  target_group_name_long  = "tg-${data.aws_eks_cluster.given.name}-nginx"
  target_group_name_short = "tg-${var.solution_fqn}-nginx"
  target_group_name       = length(local.target_group_name_long) <= 32 ? local.target_group_name_long : local.target_group_name_short
  target_host_names       = var.load_balancer_strategy == "SERVICE_VIA_TARGET_GROUP_BINDING" ? var.host_names : []
}

# create a target group all ingress controller pods are registered to
resource "aws_lb_target_group" "ingress" {
  count       = var.load_balancer_strategy == "SERVICE_VIA_TARGET_GROUP_BINDING" ? 1 : 0
  name        = local.target_group_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_lb.given[0].vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    matcher             = "200,404"
  }

  tags = merge({ Name = local.target_group_name }, local.module_common_tags)
}

# add forwarding rule from given loadbalancer to newly created target group
resource "aws_lb_listener_rule" "ingress" {
  for_each     = toset(local.target_host_names)
  listener_arn = data.aws_lb_listener.given[0].id
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress[0].arn
  }
  condition {
    host_header {
      values = [each.value]
    }
  }
}