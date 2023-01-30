output "vpc_id" {
  description = "Unique identifier of the newly created VPC network."
  value       = aws_vpc.vpc.id
}

output "vpc_name" {
  description = "Fully qualified name of the newly created VPC network."
  value       = aws_vpc.vpc.tags["Name"]
}

output "subnets" {
  description = "Information about created subnets"
  value = [for sn in aws_subnet.subnets : {
    subnet_name          = sn.tags["Name"]
    subnet_id            = sn.id
    subnet_template_name = sn.tags["TemplateName"]
    zone_name            = sn.availability_zone
    accessibility        = sn.tags["Accessibility"]
  }]
}
