locals {
  certificates_values = <<EOT
ingress:
  certificates:
    organizations:
%{ for org in var.organization_names ~}
    - ${org}
%{ endfor ~}
    dnsNames:
%{ for domain in var.domain_names ~}
    - ${domain}
%{ endfor ~}
    issuer:
      name: letsencrypt-${var.letsencrypt_environment}
EOT
}

resource "helm_release" "ingress_certificates" {
  chart             = "${path.module}/resources/helm/ingress_certificates"
  name              = var.helm_release_name
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  namespace         = var.kubernetes_namespace_name
  create_namespace  = true
  values            = [ local.certificates_values ]
}