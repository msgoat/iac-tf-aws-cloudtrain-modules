output k8s_secret_name {
  description = "Name of the Kubernetes secrets which holds all connection information to the given PostgreSQL instance"
  value = local.db_instance_name
}