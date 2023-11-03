output alb_arn {
  description = "ARN of an Application Load Balancer managed by the AWS Load Balancer Controller, if `load_balancer_strategy` == 'INGRESS_VIA_ALB'"
  value = "" # var.load_balancer_strategy == "INGRESS_VIA_ALB" ? data.aws_alb.managed[0].arn : ""
}

output ingress_controller {
  description = "Metadata defining the endpoints of the newly created ingress controller"
  value = {
    name = "nginx"
    type = "NGINX"
    protocol = "HTTP"
    port = 32080
    health_probe_path = "/healthz"
    health_probe_protocol = "HTTP"
    health_probe_port = 32080
    health_probe_success_codes = [ "200", "404"]
  }
}