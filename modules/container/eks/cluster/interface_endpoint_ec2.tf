locals {
  ec2_security_group_suffix = "${var.region_name}-${var.solution_fqn}-${var.kubernetes_cluster_name}-ec2"
}

resource aws_vpc_endpoint private_ec2 {
  count = var.private_endpoint_enabled ? 1 : 0
  vpc_id = data.aws_subnet.node_group[0].vpc_id
  private_dns_enabled = true
  subnet_ids = data.aws_subnet.node_group.*.id
  security_group_ids = [ aws_security_group.private_ec2[0].id ]
  service_name = "com.amazonaws.${var.region_name}.ec2"
  vpc_endpoint_type = "Interface"
  tags = merge({
    Name = "vpce-${var.region_name}-${var.solution_fqn}-${var.kubernetes_cluster_name}-ec2"
  }, local.module_common_tags)
}

resource aws_security_group private_ec2 {
  count = var.private_endpoint_enabled ? 1 : 0
  name = "sec-${local.ec2_security_group_suffix}"
  vpc_id = data.aws_subnet.node_group[0].vpc_id
  tags = merge({
    Name = "sg-${local.ec2_security_group_suffix}"
  }, local.module_common_tags)
}

resource aws_security_group_rule ingress_private_ec2 {
  count = var.private_endpoint_enabled ? 1 : 0
  security_group_id = aws_security_group.private_ec2[0].id
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = data.aws_subnet.node_group.*.cidr_block
}