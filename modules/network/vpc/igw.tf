locals {
  igw_name = "igw-${var.region_name}-${var.solution_fqn}-${lower(var.network_name)}"
}

# create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ Name = local.igw_name }, local.module_common_tags)
}

locals {
  igw_route_table_keys = [ for k, v in local.subnets_by_keys : k if v.accessibility == "public"]
}

# add a route to the route tables of all public subnets that routes all internet-bound traffic
# through the internet gateway
resource "aws_route" "igw" {
  for_each               = toset(local.igw_route_table_keys)
  route_table_id         = aws_route_table.this[each.value].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


