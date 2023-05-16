output alb_arn {
  description = "ARN of an Application Load Balancer which forwards traffic to the ingress controller"
  value = module.loadbalancer.loadbalancer_id
}