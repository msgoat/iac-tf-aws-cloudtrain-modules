output alb_arn {
  description = "ARN of an Application Load Balancer managed by the AWS Load Balancer Controller, if `load_balancer_strategy` == 'INGRESS_VIA_ALB'"
  value = var.load_balancer_strategy == "INGRESS_VIA_ALB" ? data.aws_alb.this[0].arn : ""
}