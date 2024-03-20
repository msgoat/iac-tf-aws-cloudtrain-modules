resource random_string db_user {
  length = 16
  special = false
}

resource random_password db_password {
  length = 25
  special = var.generate_url_friendly_password ? false : true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}