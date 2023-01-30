data aws_subnet loadbalancer_subnets {
  count = length(var.loadbalancer_subnet_ids)
  id = var.loadbalancer_subnet_ids[count.index]
}

data aws_subnet target_group_subnets {
  count = length(var.target_group_subnet_ids)
  id = var.target_group_subnet_ids[count.index]
}

