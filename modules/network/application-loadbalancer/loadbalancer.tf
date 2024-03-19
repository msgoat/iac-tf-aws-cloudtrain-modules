# loadbalancer.tf
#----------------------------------------------------------------------
# Creates an Application Loadbalancer
#----------------------------------------------------------------------
#

locals {
  alb_name_long = "alb-${var.region_name}-${var.solution_fqn}-${var.loadbalancer_name}"
  alb_name_short = "alb-${var.solution_fqn}-${var.loadbalancer_name}"
  alb_name = length(local.alb_name_long) <= 32 ? local.alb_name_long : local.alb_name_short
  alb_security_group_ids = length(var.target_security_group_ids) != 0 ? concat([ aws_security_group.this.id ], var.target_security_group_ids) : [ aws_security_group.this.id ]
}

resource aws_lb this {
  name = local.alb_name
  internal = false
  load_balancer_type = "application"
  security_groups = local.alb_security_group_ids
  subnets = data.aws_subnet.given.*.id
  tags = merge({ Name = local.alb_name }, local.module_common_tags)
}

# --- listeners

resource aws_lb_listener http {
  load_balancer_arn = aws_lb.this.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource aws_lb_listener https {
  load_balancer_arn = aws_lb.this.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = var.ssl_security_policy
  certificate_arn = var.cm_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code = 404
      message_body = "Default action: no target found! Did you forget to attach a target group?"
    }
  }
}

