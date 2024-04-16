# Add additional rules to the cluster security group which allow inbound HTTP traffic from within the VPC.
# Traffic forwarding from a load balancer in front of the cluster using pod IPs won't work, otherwise.

resource "aws_security_group_rule" "allow_inbound_http_from_vpc" {
  description       = "Allow inbound HTTP traffic from VPC"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.given.cidr_block]
  security_group_id = aws_eks_cluster.control_plane.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "allow_inbound_https_from_vpc" {
  description       = "Allow inbound HTTPS traffic from VPC"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.given.cidr_block]
  security_group_id = aws_eks_cluster.control_plane.vpc_config[0].cluster_security_group_id
}
