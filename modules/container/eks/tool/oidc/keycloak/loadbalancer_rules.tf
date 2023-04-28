resource aws_lb_listener_rule keycloak {
  listener_arn = data.aws_lb_listener.https.arn
  condition {
    host_header {
      values = ["oidc.${var.public_dns_zone_name}"]
    }
  }
  action {
    type = "forward"
    target_group_arn = data.aws_lb_target_group.default.arn
  }
}
