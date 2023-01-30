output loadbalancer_id {
  description = "Unique identifier of the newly created Application Loadbalancer"
  value = aws_lb.loadbalancer.id
}

output loadbalancer_security_group_id {
  description = "Unique identifier of the security group assigned to the newly created Application Loadbalancer"
  value = aws_security_group.loadbalancer.id
}

output loadbalancer_target_group_id {
  description = "Unique identifier of the newly created target group"
  value = aws_lb_target_group.ingress.id
}