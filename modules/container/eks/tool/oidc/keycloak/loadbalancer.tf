data aws_lb loadbalancer {
  arn = var.loadbalancer_id
}

data aws_lb_listener https {
  load_balancer_arn = data.aws_lb.loadbalancer.arn
  port = 443
}

data aws_lb_target_group default {
  arn = var.loadbalancer_target_group_id
}