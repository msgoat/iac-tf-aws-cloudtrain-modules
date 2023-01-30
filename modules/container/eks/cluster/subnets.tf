// retrieve the subnets supposed to host the node groups
data aws_subnet node_group {
  count = length(var.node_group_subnet_ids)
  id = var.node_group_subnet_ids[count.index]
}
