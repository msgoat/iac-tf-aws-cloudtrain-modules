data aws_lb given {
  arn = var.loadbalancer_id
}

data aws_lb_listener given {
  load_balancer_arn = data.aws_lb.given.arn
  port = 443
}

data aws_lb_target_group default {
  arn = var.loadbalancer_target_group_id
}