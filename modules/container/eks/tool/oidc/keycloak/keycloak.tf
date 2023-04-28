resource helm_release keycloak {
  chart = "keycloak"
  version = "10.1.0"
  repository = "https://codecentric.github.io/helm-charts"
  name = var.helm_release_name
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  namespace = module.namespace.kubernetes_namespace_name
  values = [file("${path.module}/resources/helm/keycloak/values.yaml")]
  set {
    name = "ingress.rules[0].host"
    value = "oidc.${var.public_dns_zone_name}"
  }
  set {
    name = "ingress.frontendUrl"
    value = "https://oidc.${var.public_dns_zone_name}/auth/"
  }
  depends_on = [ kubernetes_secret.keycloak_db ]
}