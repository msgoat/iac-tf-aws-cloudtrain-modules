data aws_vpc given {
  id = data.aws_subnet.given[0].vpc_id
}