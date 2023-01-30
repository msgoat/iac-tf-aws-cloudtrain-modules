# nat_gateways.tf

locals {
  // filter all zones which have public and private subnets
  names_of_zones_with_public_and_private_subnets = tolist(setintersection(keys(local.public_subnet_templates_by_zone), keys(local.private_subnet_templates_by_zone)))
  multi_az_nat_gateway_keys                      = local.names_of_zones_with_public_and_private_subnets
  multi_az_nat_gateway_values = [for k in local.multi_az_nat_gateway_keys : {
    subnet_key       = local.public_subnet_templates_by_zone[k][0].subnet_key
    nat_gateway_key  = k
    zone_name        = k
    nat_gateway_name = "ngw-${k}-${var.solution_fqn}-${var.network_name}"
    eip_key          = k
    eip_name         = "eip-${k}-${var.solution_fqn}-${var.network_name}-ngw"
  }]
  multi_az_nat_gateways         = zipmap(local.multi_az_nat_gateway_keys, local.multi_az_nat_gateway_values)
  multi_az_nat_gateways_by_zone = local.multi_az_nat_gateways
  single_nat_gateway_keys       = length(local.names_of_zones_with_public_and_private_subnets) != 0 ? slice(local.names_of_zones_with_public_and_private_subnets, 0, 1) : []
  single_nat_gateway_values = [for k in local.single_nat_gateway_keys : {
    subnet_key       = local.public_subnet_templates_by_zone[k][0].subnet_key
    nat_gateway_key  = k
    zone_name        = k
    nat_gateway_name = "ngw-${k}-${var.solution_fqn}-${var.network_name}"
    eip_key          = k
    eip_name         = "eip-${k}-${var.solution_fqn}-${var.network_name}-ngw"
  }]
  single_nat_gateway         = zipmap(local.single_nat_gateway_keys, local.single_nat_gateway_values)
  single_nat_gateway_by_zone = zipmap(local.multi_az_nat_gateway_keys, [for k in local.multi_az_nat_gateway_keys : local.single_nat_gateway_values[0]])
  no_nat_gateway             = {}
  no_nat_gateway_by_zone     = {}
  nat_gateways               = var.nat_strategy == "NAT_GATEWAY_SINGLE" ? local.single_nat_gateway : (var.nat_strategy == "NAT_GATEWAY_AZ" ? local.multi_az_nat_gateways : local.no_nat_gateway)
  nat_gateways_by_zone       = var.nat_strategy == "NAT_GATEWAY_SINGLE" ? local.single_nat_gateway_by_zone : (var.nat_strategy == "NAT_GATEWAY_AZ" ? local.multi_az_nat_gateways_by_zone : local.no_nat_gateway_by_zone)
}

# create NAT gateway(s)
resource "aws_nat_gateway" "nat" {
  for_each      = local.nat_gateways
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.subnets[each.value.subnet_key].id
  tags = merge({
    Name = each.value.nat_gateway_name
  }, local.module_common_tags)
}

# create Elastic IPs (EIP) to assign to NAT gateway
resource "aws_eip" "nat" {
  for_each = local.nat_gateways
  vpc      = true
  tags = merge({
    Name = each.value.eip_name
  }, local.module_common_tags)
}

# add a route to the common route tables of all private subnets which routes all internet-bound traffic from private subnets to the NAT gateway in the same AZ
resource "aws_route" "ngw" {
  for_each               = length(local.nat_gateways) != 0 ? local.private_route_tables : {}
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[local.nat_gateways_by_zone[each.value.zone_name].nat_gateway_key].id
}
