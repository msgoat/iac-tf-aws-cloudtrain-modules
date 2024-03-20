locals {
  actual_zones_to_span = var.zones_to_span == 0 ? length(data.aws_availability_zones.available_zones) : var.zones_to_span
  zone_numbers         = range(1, local.actual_zones_to_span + 1)
  zone_names           = [for pair in setproduct(["az"], local.zone_numbers) : "${pair[0]}${pair[1]}"]
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}
