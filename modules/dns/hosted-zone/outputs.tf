output "hosted_zone_name" {
  description = "Fully qualified name of the Route 53 hosted zone."
  value       = aws_route53_zone.this.name
}

output "hosted_zone_id" {
  description = "Unique identifier of the Route 53 hosted zone."
  value       = aws_route53_zone.this.zone_id
}

output "hosted_zone_arn" {
  description = "ARN of the Route 53 hosted zone."
  value       = aws_route53_zone.this.arn
}
