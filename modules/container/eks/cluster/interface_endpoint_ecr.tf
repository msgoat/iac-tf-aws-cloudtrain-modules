locals {
  ecr_security_group_suffix = "${var.region_name}-${var.solution_fqn}-${var.kubernetes_cluster_name}-ecr"
}

resource aws_vpc_endpoint private_ecr_api {
  count = var.private_endpoint_enabled ? 1 : 0
  vpc_id = data.aws_subnet.node_group[0].vpc_id
  private_dns_enabled = true
  subnet_ids = data.aws_subnet.node_group.*.id
  security_group_ids = [ aws_security_group.private_ecr[0].id ]
  service_name = "com.amazonaws.${var.region_name}.ecr.api"
  vpc_endpoint_type = "Interface"
  tags = merge({
    Name = "vpce-${var.region_name}-${var.solution_fqn}-${var.kubernetes_cluster_name}-ecrapi"
  }, local.module_common_tags)
}

resource aws_vpc_endpoint private_ecr_docker {
  count = var.private_endpoint_enabled ? 1 : 0
  vpc_id = data.aws_subnet.node_group[0].vpc_id
  private_dns_enabled = true
  subnet_ids = data.aws_subnet.node_group.*.id
  security_group_ids = [ aws_security_group.private_ecr[0].id ]
  service_name = "com.amazonaws.${var.region_name}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  tags = merge({
    Name = "vpce-${var.region_name}-${var.solution_fqn}-${var.kubernetes_cluster_name}-ecrdkr"
  }, local.module_common_tags)
}

resource aws_security_group private_ecr {
  count = var.private_endpoint_enabled ? 1 : 0
  name = "sec-${local.ecr_security_group_suffix}"
  vpc_id = data.aws_subnet.node_group[0].vpc_id
  tags = merge({
    Name = "sg-${local.ecr_security_group_suffix}"
  }, local.module_common_tags)
}

resource aws_security_group_rule ingress_private_ecr {
  count = var.private_endpoint_enabled ? 1 : 0
  security_group_id = aws_security_group.private_ecr[0].id
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = data.aws_subnet.node_group.*.cidr_block
}