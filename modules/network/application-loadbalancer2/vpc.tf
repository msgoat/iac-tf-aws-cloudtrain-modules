data aws_vpc vpc {
  id = data.aws_subnet.loadbalancer_subnets[0].vpc_id
}

