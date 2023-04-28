provider helm {
  kubernetes {
    config_path = var.kube_config_file_name
  }
}