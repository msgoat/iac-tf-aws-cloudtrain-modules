locals {
  // calculate number of availability zones to span
  number_of_zones_to_span = length(var.zones_to_span)
  // retrieve names of all availability zones to span
  names_of_zones_to_span = var.zones_to_span
  // build product of availability zones to span and given subnets to repeat given subnets in each spanned zone
  subnets_by_zone = [for pair in setproduct(local.names_of_zones_to_span, var.subnet_templates) : {
    subnet_key           = "${pair[1].name}-${pair[0]}"
    subnet_name          = "sn-${pair[0]}-${var.solution_fqn}-${var.network_name}-${pair[1].name}"
    subnet_template_name = pair[1].name
    zone_name            = pair[0]
    accessibility        = pair[1].accessibility
    newbits              = pair[1].newbits
    role                 = pair[1].role
    tags                 = pair[1].tags
  }]
  subnet_keys     = [for sn in local.subnets_by_zone : sn.subnet_key]
  subnets_by_keys = zipmap(local.subnet_keys, local.subnets_by_zone)
}

// create a subnet based on each subnet template
resource "aws_subnet" "subnets" {
  for_each                = local.subnets_by_keys
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.zone_name
  map_public_ip_on_launch = each.value.accessibility == "public" ? true : false
  cidr_block              = cidrsubnet(var.network_cidr, each.value.newbits, index(local.subnet_keys, each.key) + 1)
  tags = merge({
    Name          = each.value.subnet_name
    TemplateName  = each.value.subnet_template_name
    Accessibility = each.value.accessibility
    Role          = each.value.role
  }, each.value.tags, local.module_common_tags)
}

locals {
  subnet_infos = [
    for sn in aws_subnet.subnets : {
      subnet_name          = sn.tags["Name"]
      subnet_id            = sn.id
      subnet_template_name = sn.tags["TemplateName"]
      zone_name            = sn.availability_zone
      accessibility        = sn.tags["Accessibility"]
      role                 = sn.tags["Role"]
    }
  ]
}