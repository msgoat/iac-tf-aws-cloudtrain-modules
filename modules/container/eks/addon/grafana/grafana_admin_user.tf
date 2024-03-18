resource random_string grafana_admin {
  length = 8
  special = false
}

resource random_password grafana_admin {
  length = 16
  special = true
  override_special = "!=+-:.;,-_<>"
}