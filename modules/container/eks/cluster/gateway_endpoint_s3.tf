resource aws_vpc_endpoint private_s3 {
  count = var.private_endpoint_enabled ? 1 : 0
  vpc_id = data.aws_subnet.node_group[0].vpc_id
  vpc_endpoint_type = "Gateway"
  service_name = "com.amazonaws.${var.region_name}.s3"
  route_table_ids = data.aws_route_table.node_group.*.id
  tags = merge({
    Name = "vpce-${var.region_name}-${var.solution_fqn}-${var.kubernetes_cluster_name}-s3"
  }, local.module_common_tags)
}

data aws_route_table node_group {
  count = length(var.node_group_subnet_ids)
  subnet_id = var.node_group_subnet_ids[count.index]
}
