output loadbalancer_fqn {
  description = "Fully qualified name of the newly created Application Loadbalancer"
  value = aws_lb.this.tags["Name"]
}

output loadbalancer_id {
  description = "Unique identifier of the newly created Application Loadbalancer"
  value = aws_lb.this.id
}

output loadbalancer_arn {
  description = "ARN of the newly created Application Loadbalancer"
  value = aws_lb.this.arn
}

output loadbalancer_security_group_id {
  description = "Unique identifier of the security group assigned to the newly created Application Loadbalancer"
  value = aws_security_group.this.id
}
