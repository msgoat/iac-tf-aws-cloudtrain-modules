resource kubernetes_secret keycloak_db {
  type = "Opaque"
  metadata {
    name = "keycloak-postgresql"
    namespace = module.namespace.kubernetes_namespace_name
    labels = {
      "app.kubernetes.io/name" = "keycloak-postgresql"
      "app.kubernetes.io/instance" = "keycloak-postgresql"
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
  data = {
    postgresql-host = module.postgresql.db_host_name
    postgresql-port = module.postgresql.db_port_number
    postgresql-user = module.postgresql.db_user_name
    postgresql-password = module.postgresql.db_user_password
  }
}