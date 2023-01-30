resource aws_security_group cluster_shared_node {
  count = var.loadbalancer_security_group_enabled ? 1 : 0
  name = "sec-${local.eks_cluster_name}-cluster-shared-node"
  description = "controls traffic between worker nodes"
  vpc_id = data.aws_subnet.node_group[0].vpc_id
  tags = merge({
    Name = "sg-${local.eks_cluster_name}-cluster-shared-node"
  }, local.module_common_tags)
}

resource aws_security_group_rule allow_any_ingress_from_lb {
  count = var.loadbalancer_security_group_enabled ? 1 : 0
  type = "ingress"
  description = "allow any inbound traffic from loadbalancer to ingress controller using node ports"
  from_port = 30000
  to_port = 32767
  protocol = "TCP"
  source_security_group_id = aws_security_group.lb_to_ingress[0].id
  security_group_id = aws_security_group.cluster_shared_node[0].id
}

resource aws_security_group_rule allow_any_egress_from_nodes {
  count = var.loadbalancer_security_group_enabled ? 1 : 0
  type = "egress"
  description = "allow any outbound traffic from nodes"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster_shared_node[0].id
}

resource aws_security_group lb_to_ingress {
  count = var.loadbalancer_security_group_enabled ? 1 : 0
  name = "sec-${local.eks_cluster_name}-lb-to-ingress"
  description = "controls traffic between external loadbalancer and ingress controller"
  vpc_id = data.aws_subnet.node_group[0].vpc_id
  tags = merge({
    Name = "sg-${local.eks_cluster_name}-lb-to-ingress"
  }, local.module_common_tags)
}

resource aws_security_group_rule allow_any_egress_from_lb {
  count = var.loadbalancer_security_group_enabled ? 1 : 0
  type = "egress"
  description = "allow any outbound traffic from external loadbalancer to ingress controller"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_to_ingress[0].id
}
