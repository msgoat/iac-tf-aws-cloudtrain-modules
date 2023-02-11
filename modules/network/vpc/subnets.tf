locals {
  // calculate number of availability zones to span
  number_of_zones_to_span = var.zones_to_span == 0 ? length(data.aws_availability_zones.zones.names) : var.zones_to_span
  // retrieve names of all availability zones to span
  names_of_zones_to_span = slice(data.aws_availability_zones.zones.names, 0, local.number_of_zones_to_span)
  // convert given list of subnets to map
  given_subnet_names    = [for sn in var.subnets : sn.subnet_name]
  given_subnets_by_name = zipmap(local.given_subnet_names, var.subnets)
  // build product of availability zones to span and given subnets to repeat given subnets in each spanned zone
  subnets_per_zone = [for pair in setproduct(local.names_of_zones_to_span, local.given_subnet_names) : {
    subnet_name       = "sn-${pair[0]}-${var.solution_fqn}-${var.network_name}-${pair[1]}"
    given_subnet_name = pair[1]
    zone_name         = pair[0]
  }]
  // build map with subnet name / subnet index entries
  subnet_names         = [for sn in local.subnets_per_zone : sn.subnet_name]
  subnet_indexes       = range(0, length(local.subnet_names))
  subnet_index_by_name = zipmap(local.subnet_names, local.subnet_indexes)
  // build map of subnet template key / values with stable keys
  subnet_template_keys = [for sn in local.subnets_per_zone : "${sn.zone_name}-${sn.given_subnet_name}"]
  subnet_template_values = [for spz in local.subnets_per_zone : {
    subnet_key        = "${spz.zone_name}-${spz.given_subnet_name}"
    subnet_name       = spz.subnet_name
    given_subnet_name = spz.given_subnet_name
    zone_name         = spz.zone_name
    accessibility     = local.given_subnets_by_name[spz.given_subnet_name].accessibility
    newbits           = local.given_subnets_by_name[spz.given_subnet_name].newbits
    tags              = local.given_subnets_by_name[spz.given_subnet_name].tags
    subnet_number     = local.subnet_index_by_name[spz.subnet_name] + 1
  }]
  subnet_templates = zipmap(local.subnet_template_keys, local.subnet_template_values)
  // build a map of subnet_template_values by zone
  subnet_templates_by_zone_keys   = distinct([for v in local.subnet_template_values : v.zone_name])
  subnet_templates_by_zone_values = [for k in local.subnet_templates_by_zone_keys : [for v in local.subnet_template_values : v if v.zone_name == k]]
  subnet_templates_by_zone        = zipmap(local.subnet_templates_by_zone_keys, local.subnet_templates_by_zone_values)
  // filter subnet templates for public subnet templates
  public_subnet_template_values = [for v in local.subnet_template_values : v if v.accessibility == "public"]
  public_subnet_template_keys   = [for v in local.subnet_template_values : v.subnet_key if v.accessibility == "public"]
  public_subnet_templates       = zipmap(local.public_subnet_template_keys, local.public_subnet_template_values)
  // build a map of public subnet_template_values by zone
  public_subnet_templates_by_zone_keys   = distinct([for v in local.public_subnet_template_values : v.zone_name])
  public_subnet_templates_by_zone_values = [for k in local.public_subnet_templates_by_zone_keys : [for v in local.public_subnet_template_values : v if v.zone_name == k]]
  public_subnet_templates_by_zone        = zipmap(local.public_subnet_templates_by_zone_keys, local.public_subnet_templates_by_zone_values)
  // filter subnet templates for private subnet templates
  private_subnet_template_values = [for v in local.subnet_template_values : v if v.accessibility == "private"]
  private_subnet_template_keys   = [for v in local.subnet_template_values : v.subnet_key if v.accessibility == "private"]
  private_subnet_templates       = zipmap(local.private_subnet_template_keys, local.private_subnet_template_values)
  // build a map of private subnet_template_values by zone
  private_subnet_templates_by_zone_keys   = distinct([for v in local.private_subnet_template_values : v.zone_name])
  private_subnet_templates_by_zone_values = [for k in local.private_subnet_templates_by_zone_keys : [for v in local.private_subnet_template_values : v if v.zone_name == k]]
  private_subnet_templates_by_zone        = zipmap(local.private_subnet_templates_by_zone_keys, local.private_subnet_templates_by_zone_values)
}

// create a subnet based on each subnet template
resource "aws_subnet" "subnets" {
  for_each                = local.subnet_templates
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.zone_name
  map_public_ip_on_launch = each.value.accessibility == "public" ? true : false
  cidr_block              = cidrsubnet(var.network_cidr, each.value.newbits, each.value.subnet_number)
  tags = merge({
    Name          = each.value.subnet_name
    TemplateName  = each.value.given_subnet_name
    Accessibility = each.value.accessibility
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
    }
  ]
}