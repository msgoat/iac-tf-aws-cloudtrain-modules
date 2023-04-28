locals {
  # make sure that random user name does not start with a digit
  db_master_user_name = length(regexall("^[[:digit:]]", random_string.db_user.result)) > 0 ? "pg${random_string.db_user.result}" : random_string.db_user.result
  db_instance_name = "postgres-${var.region_name}-${var.solution_fqn}-${var.db_instance_name}"
  final_db_snapshot_name = var.final_db_snapshot_enabled ? "snap-${local.db_instance_name}" : null
}

resource aws_db_instance postgresql {
  identifier = local.db_instance_name
  db_name = var.db_database_name
  engine = "postgres"
  engine_version = var.postgresql_version
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = true
  instance_class = var.db_instance_class
  storage_type = var.db_storage_type
  allocated_storage = var.db_min_storage_size
  max_allocated_storage = var.db_max_storage_size
  storage_encrypted = true
  backup_retention_period = 7
  # backup_window = "22:00-23:59"
  delete_automated_backups = true
  skip_final_snapshot = !var.final_db_snapshot_enabled
  final_snapshot_identifier = local.final_db_snapshot_name
  snapshot_identifier = var.db_snapshot_id
  # maintenance_window = "00:00-06:00"
  copy_tags_to_snapshot = true
  username =  local.db_master_user_name
  password = random_password.db_password.result
  iam_database_authentication_enabled = true
  db_subnet_group_name = aws_db_subnet_group.postgresql.name
  vpc_security_group_ids = [aws_security_group.postgresql.id]
  kms_key_id = aws_kms_key.cmk.arn
  tags = merge({
    Name = local.db_instance_name
  }, local.module_common_tags)
  depends_on = [
    # postgres creation seems to be related to secret creation
    aws_secretsmanager_secret.postgres,
    aws_secretsmanager_secret_version.postgres
  ]
}