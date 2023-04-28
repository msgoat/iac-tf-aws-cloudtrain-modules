resource random_string keycloak_user {
  length = 16
  special = false
}

resource random_password keycloak_password {
  length = 25
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}