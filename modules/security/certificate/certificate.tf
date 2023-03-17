# certificate.tf
#----------------------------------------------------------------
# creates a TLS certificate for HTTPS communication
#----------------------------------------------------------------
#

# create a new TLS certificate if no TLS certificate name has been given
resource aws_acm_certificate cert {
  domain_name = var.domain_name
  subject_alternative_names = var.alternative_domain_names
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = "cert-${var.region_name}-${var.solution_fqn}-${var.certificate_name}"}, local.module_common_tags)
}

# retrieve the hosted zones for all non-wildcard host names
data aws_route53_zone hosted_zone {
  name = var.domain_name
  private_zone = false
}

locals {
  cert_validation_records = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.hosted_zone.zone_id
    }
  }
}
# create the DNS records for certificate validation if no TLS certificate name has been given
resource aws_route53_record cert_validation {
  for_each = local.cert_validation_records
  allow_overwrite = true
  name            = each.value.name
  records         = [ each.value.record ]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

# perform the DNS certificate validation
resource aws_acm_certificate_validation cert {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for rec in aws_route53_record.cert_validation : rec.fqdn]
}

