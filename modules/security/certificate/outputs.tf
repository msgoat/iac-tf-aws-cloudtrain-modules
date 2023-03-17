output "cm_certificate_name" {
  description = "Fully qualified name of the certificate managed by AWS Certificate Manager."
  value       = aws_acm_certificate.cert.tags["Name"]
}

output "cm_certificate_id" {
  description = "Unique identifier of the certificate managed by AWS Certificate Manager."
  value       = aws_acm_certificate.cert.id
}

output "cm_certificate_arn" {
  description = "ARN of the certificate managed by AWS Certificate Manager."
  value       = aws_acm_certificate.cert.arn
}
