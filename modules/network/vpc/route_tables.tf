# create a custom route table for each subnet to avoid side effects when changing routes
resource "aws_route_table" "this" {
  for_each = local.subnets_by_keys
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    Name = "rtb-${each.value.zone_name}-${var.solution_fqn}-${each.value.subnet_template_name}"
    Accessibility = each.value.accessibility
  }, local.module_common_tags)
}

# associate each custom route table with its corresponding subnet
resource "aws_route_table_association" "this" {
  for_each       = local.subnets_by_keys
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}
