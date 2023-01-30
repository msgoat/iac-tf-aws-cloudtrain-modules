resource aws_lb_listener_rule rules {
  for_each = local.route_templates
  listener_arn = data.aws_lb_listener.given.arn
  condition {
    host_header {
      values = [ each.value.host_name ]
    }
  }
  action {
    type = "forward"
    target_group_arn = data.aws_lb_target_group.default.arn
  }
}
