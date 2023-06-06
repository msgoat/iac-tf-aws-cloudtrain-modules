module "vpc" {
  source                = "../vpc"
  common_tags           = local.module_common_tags
  inbound_traffic_cidrs = var.inbound_traffic_cidrs
  nat_strategy          = var.nat_strategy
  network_cidr          = var.network_cidr
  network_name          = var.network_name
  region_name           = var.region_name
  solution_name         = var.solution_name
  solution_stage        = var.solution_stage
  solution_fqn          = var.solution_fqn
  zones_to_span         = var.zones_to_span
  subnet_templates = [
    {
      name          = "web"
      role          = "InternetFacingContainer"
      accessibility = "public"
      newbits       = 8
      tags          = {}
    },
    {
      name          = "app"
      role          = "ApplicationContainer"
      accessibility = "private"
      newbits       = 4
      tags          = {}
    },
    {
      name          = "data"
      role          = "DatabaseContainer"
      accessibility = "private"
      newbits       = 4
      tags          = {}
    }
  ]
}