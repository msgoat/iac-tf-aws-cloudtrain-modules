resource kubernetes_secret keycloak_admin {
  type = "Opaque"
  metadata {
    name = "keycloak-admin"
    namespace = module.namespace.kubernetes_namespace_name
    labels = {
      "app.kubernetes.io/name" = "keycloak-admin"
      "app.kubernetes.io/instance" = "keycloak-admin"
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
  data = {
    keycloak-user = random_string.keycloak_user.result
    keycloak-password = random_password.keycloak_password.result
  }
}