output "vpc_id" {
  description = "Unique identifier of the newly created VPC network."
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "Fully qualified name of the newly created VPC network."
  value       = module.vpc.vpc_name
}

output "public_subnet_ids" {
  description = "Unique identifiers of all public subnets"
  value       = [for sn in module.vpc.subnets : sn.subnet_id if sn.accessibility == "public"]
}

output "private_subnet_ids" {
  description = "Unique identifiers of all private subnets"
  value       = [for sn in module.vpc.subnets : sn.subnet_id if sn.accessibility == "private"]
}

output "web_subnet_ids" {
  description = "Unique identifiers of all web subnets"
  value       = [for sn in module.vpc.subnets : sn.subnet_id if sn.subnet_template_name == "web"]
}

output "app_subnet_ids" {
  description = "Unique identifiers of all application subnets"
  value       = [for sn in module.vpc.subnets : sn.subnet_id if sn.subnet_template_name == "app"]
}

output "data_subnet_ids" {
  description = "Unique identifiers of all datastore subnets"
  value       = [for sn in module.vpc.subnets : sn.subnet_id if sn.subnet_template_name == "data"]
}
