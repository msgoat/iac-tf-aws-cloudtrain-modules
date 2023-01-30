locals {
  public_subnet_ids                   = [for sn in aws_subnet.subnets : sn.id if sn.tags["Accessibility"] == "public"]
  private_subnet_ids                  = [for sn in aws_subnet.subnets : sn.id if sn.tags["Accessibility"] == "private"]
  names_of_zones_with_private_subnets = distinct([for sn in aws_subnet.subnets : sn.availability_zone if sn.tags["Accessibility"] == "private"])
  private_subnets_by_zone_keys        = distinct([for sn in aws_subnet.subnets : sn.availability_zone if sn.tags["Accessibility"] == "private"])
  private_subnets_by_zone_values = [for sn in aws_subnet.subnets : {

  } if sn.tags["Accessibility"] == "private"]
  public_route_table_keys = distinct([for v in local.public_subnet_template_values : v.zone_name])
  public_route_table_values = [for k in local.public_route_table_keys : {
    route_table_key  = k
    route_table_name = "rtb-${k}-${var.solution_fqn}-${var.network_name}-public"
  }]
  public_route_tables      = zipmap(local.public_route_table_keys, local.public_route_table_values)
  private_route_table_keys = [for v in local.private_subnet_template_values : v.subnet_key]
  private_route_table_values = [for v in local.private_subnet_template_values : {
    route_table_key  = v.subnet_key
    subnet_key       = v.subnet_key
    zone_name        = v.zone_name
    route_table_name = "rtb-${v.zone_name}-${var.solution_fqn}-${var.network_name}-${v.given_subnet_name}-private"
  }]
  private_route_tables = zipmap(local.private_route_table_keys, local.private_route_table_values)
}

# create common custom gateway route table for all public subnets in each availability zones
resource "aws_route_table" "public" {
  for_each = local.public_route_tables
  vpc_id   = aws_vpc.vpc.id
  tags = merge({
    Name = each.value.route_table_name
  }, local.module_common_tags)
}

# associate these custom gateway route tables with all public subnets in each availability zone
resource "aws_route_table_association" "public" {
  for_each       = local.public_subnet_templates
  subnet_id      = aws_subnet.subnets[each.value.subnet_key].id
  route_table_id = aws_route_table.public[each.value.zone_name].id
}

# create a dedicated custom gateway route table for each private subnet
resource "aws_route_table" "private" {
  for_each = local.private_route_tables
  vpc_id   = aws_vpc.vpc.id
  tags = merge({
    Name = each.value.route_table_name
  }, local.module_common_tags)
}

# associate this custom gateway route table with all private subnets in each availability zone
resource "aws_route_table_association" "private" {
  for_each       = local.private_route_tables
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
