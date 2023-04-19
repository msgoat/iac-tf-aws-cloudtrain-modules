locals {
  letencrypt_values = <<EOT
fullnameOverride: letsencrypt
letsencrypt:
  acme:
    email: ${var.letsencrypt_account_name}
    dnsZones:
      - ${var.hosted_zone_name}
    route53:
      region: ${var.region_name}
      hostedZoneId: ${data.aws_route53_zone.given.id}
EOT
}

resource "helm_release" "letsencrypt" {
  chart             = "${path.module}/resources/helm/cert-manager-letsencrypt"
  name              = "letsencrypt"
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  namespace         = var.kubernetes_namespace_name
  create_namespace  = true
  values            = [ local.letencrypt_values ]
  depends_on = [helm_release.cert_manager]
}