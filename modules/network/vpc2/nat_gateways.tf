# nat_gateways.tf

locals {
  // Create a dedicated nat gateway template for each zone when var.nat_strategy == "NAT_NONE"
  no_nat_gateway_template_by_zone = []
  // Create a dedicated nat gateway template for each zone when var.nat_strategy == "NAT_GATEWAY_SINGLE"
  // - will return list with single template for one nat gateway referring to the first public subnet and to the private subnets of all zones
  single_az_nat_gateway_template_by_zone = [{
    zone_name           = local.names_of_zones_to_span[0]
    nat_gateway_key     = "nat-${local.names_of_zones_to_span[0]}"
    nat_gateway_name    = "nat-${local.names_of_zones_to_span[0]}-${var.solution_fqn}-${var.network_name}"
    eip_name            = "eip-${local.names_of_zones_to_span[0]}-${var.solution_fqn}-${var.network_name}-nat"
    public_subnet_key   = [for sn in local.subnets_by_zone : sn.subnet_key if sn.accessibility == "public"][0]
    private_subnet_keys = [for sn in local.subnets_by_zone : sn.subnet_key if sn.accessibility == "private"]
  }]
  // Create a dedicated nat gateway template for each zone when var.nat_strategy == "NAT_GATEWAY_AZ"
  // - will return list with templates for each nat gateway referring to the first public subnet of the same zone and to all private subnets in the same zone
  multi_az_nat_gateway_template_by_zone = [for z in local.names_of_zones_to_span : {
    zone_name           = z
    nat_gateway_key     = "nat-${z}"
    nat_gateway_name    = "nat-${z}-${var.solution_fqn}-${var.network_name}"
    eip_name            = "eip-${z}-${var.solution_fqn}-${var.network_name}-nat"
    public_subnet_key   = [for sn in local.subnets_by_zone : sn.subnet_key if(sn.zone_name == z) && (sn.accessibility == "public")][0]
    private_subnet_keys = [for sn in local.subnets_by_zone : sn.subnet_key if(sn.zone_name == z) && (sn.accessibility == "private")]
  }]
  nat_gateway_templates_by_zone = var.nat_strategy == "NAT_GATEWAY_SINGLE" ? local.single_az_nat_gateway_template_by_zone : (var.nat_strategy == "NAT_GATEWAY_AZ" ? local.multi_az_nat_gateway_template_by_zone : local.no_nat_gateway_template_by_zone)
  nat_gateway_keys              = [for nat in local.nat_gateway_templates_by_zone : nat.nat_gateway_key]
  nat_gateway_templates_by_key  = zipmap(local.nat_gateway_keys, local.nat_gateway_templates_by_zone)
  nat_route_templates = flatten([
    for nat in local.nat_gateway_templates_by_zone : [
      for psk in nat.private_subnet_keys : {
        subnet_key      = psk
        nat_gateway_key = nat.nat_gateway_key
      }
    ]
  ])
  nat_route_template_keys    = [for rt in local.nat_route_templates : rt.subnet_key]
  nat_route_templates_by_key = zipmap(local.nat_route_template_keys, local.nat_route_templates)
}

# Create the calculated number of NAT gateways depending on the NAT strategy
resource "aws_nat_gateway" "nat" {
  for_each      = local.nat_gateway_templates_by_key
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.subnets[each.value.public_subnet_key].id
  tags = merge({
    Name = each.value.nat_gateway_name
  }, local.module_common_tags)
}

# Create the calculated number of EIPs depending on the NAT strategy
resource "aws_eip" "nat" {
  for_each = local.nat_gateway_templates_by_key
  domain   = "vpc"
  tags = merge({
    Name = each.value.eip_name
  }, local.module_common_tags)
}

# Add a route to the route tables of each private subnet the NAT gateway is supposed to handle
resource "aws_route" "nat" {
  for_each               = local.nat_route_templates_by_key
  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.value.nat_gateway_key].id
}
