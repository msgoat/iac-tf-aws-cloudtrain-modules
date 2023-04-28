output aws_auth_config_map {
  description = "Contents of the aws-auth ConfigMap"
  value = module.aws_auth.aws_auth_config_map
}