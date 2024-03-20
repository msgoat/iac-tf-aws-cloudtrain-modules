data aws_subnet given {
  count = length(var.loadbalancer_subnet_ids)
  id = var.loadbalancer_subnet_ids[count.index]
}

