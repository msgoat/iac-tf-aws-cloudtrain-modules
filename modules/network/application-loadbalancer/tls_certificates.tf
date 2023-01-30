# tls_certificates.tf
#----------------------------------------------------------------
# creates a TLS certificate for HTTPS communication
#----------------------------------------------------------------
#

locals {
  non_wildcard_host_names = [for s in var.host_names : s if s == trimprefix(s, "*.")]
  wildcard_host_names = [for s in var.host_names : s if s != trimprefix(s, "*.")]
  domain_name = local.non_wildcard_host_names[0]
  subject_alternative_names = length(var.host_names) > 1 ? slice(var.host_names, 1, length(var.host_names)) : []
}

# retrieve the given TLS certificate if a TLS certificate name has been given
data aws_acm_certificate given {
  count = var.tls_certificate_name != "" ? 1 : 0
  domain = var.tls_certificate_name
  statuses = ["ISSUED"]
  most_recent = true
}

# create a new TLS certificate if no TLS certificate name has been given
resource aws_acm_certificate cert {
  count = var.tls_certificate_name == "" ? 1 : 0
  domain_name = local.domain_name
  subject_alternative_names = local.subject_alternative_names
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = "cert-${var.region_name}-${var.solution_fqn}-alb-${var.loadbalancer_name}"}, local.module_common_tags)
}

# retrieve the hosted zones for all non-wildcard host names if no TLS certificate name has been given
data aws_route53_zone hosted_zone {
  count = var.tls_certificate_name == "" ? length(local.non_wildcard_host_names) : 0
  name = local.non_wildcard_host_names[count.index]
  private_zone = false
}

# create the DNS records for certificate validation if no TLS certificate name has been given
resource aws_route53_record cert_validation {
  count = var.tls_certificate_name == "" ? length(aws_acm_certificate.cert[0].domain_validation_options) : 0
  allow_overwrite = true
  name            = aws_acm_certificate.cert[0].domain_validation_options[count.index].resource_record_name
  records         = [aws_acm_certificate.cert[0].domain_validation_options[count.index].resource_record_value]
  ttl             = 60
  type            = aws_acm_certificate.cert[0].domain_validation_options[count.index].resource_record_type
  zone_id         = data.aws_route53_zone.hosted_zone[0].zone_id
}

# perform the DNS certificate validation if no TLS certificate name has been given
resource aws_acm_certificate_validation cert {
  count = var.tls_certificate_name == "" ? length(local.non_wildcard_host_names) : 0
  certificate_arn = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for rec in aws_route53_record.cert_validation[0] : rec.fqdn]
}

