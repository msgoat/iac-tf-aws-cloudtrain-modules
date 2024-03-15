# security_group.tf
#----------------------------------------------------------------------
# creates the security groups supposed to protect the application loadbalancer
#----------------------------------------------------------------------
#

locals {
  security_group_name = "sec-${local.alb_name}"
}

resource aws_security_group loadbalancer {
  name = local.security_group_name
  description = "Allow inbound HTTP and HTTPS traffic from the internet"
  vpc_id = data.aws_vpc.vpc.id
  tags = merge({ Name = local.security_group_name }, local.module_common_tags)
}

resource "aws_security_group_rule" "allow_inbound_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = var.inbound_traffic_cidrs
  security_group_id = aws_security_group.loadbalancer.id
}

resource "aws_security_group_rule" "allow_inbound_https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = var.inbound_traffic_cidrs
  security_group_id = aws_security_group.loadbalancer.id
}

resource "aws_security_group_rule" "allow_outbound_any" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = aws_security_group.loadbalancer.id
}
