output keycloak_user_name {
  description = "Name of the Keycloak admin user"
  value = random_string.keycloak_user.result
}

output keycloak_user_password {
  description = "Password of the Keycloak admin user"
  value = random_password.keycloak_password.result
}