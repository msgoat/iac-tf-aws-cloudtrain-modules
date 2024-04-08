output "public_dns_zone_fqn" {
  description = "Fully qualified name of the Route 53 hosted zone."
  value       = aws_route53_zone.this.name
}

output "public_dns_zone_id" {
  description = "Unique identifier of the Route 53 hosted zone."
  value       = aws_route53_zone.this.zone_id
}

output "public_dns_zone_arn" {
  description = "ARN of the Route 53 hosted zone."
  value       = aws_route53_zone.this.arn
}

output "public_dns_zone_name_servers" {
  description = "List of DNS name servers managing the Route 53 hosted zone to be used for manual linking of DNS zones."
  value       = aws_route53_zone.this.name_servers
}
