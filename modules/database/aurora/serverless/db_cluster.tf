locals {
  db_cluster_name = "aurora-${var.region_name}-${var.solution_fqn}-${var.db_instance_name}"
  final_snapshot_id = "snap-aurora-${var.region_name}-${var.solution_fqn}-${var.db_instance_name}"
  db_master_user_name = length(regexall("^[[:digit:]]", random_string.db_user.result)) > 0 ? "au${substr(random_string.db_user.result, 2, 14)}" : random_string.db_user.result
  db_port = var.db_engine == "aurora-postgresql" ? 5432 : 0
}

resource "aws_rds_cluster" "this" {
  # allocated_storage                   = var.db_min_storage_size
  allow_major_version_upgrade         = false
  apply_immediately                   = false
  # availability_zones                  = data.aws_availability_zones.available_zones.names
  backup_retention_period             = 7
  # backtrack_window                    = local.backtrack_window
  cluster_identifier                  = local.db_cluster_name
  copy_tags_to_snapshot               = true
  database_name                       = var.db_database_name
  #db_cluster_instance_class           = var.db_instance_class
  #db_cluster_parameter_group_name     = var.create_db_cluster_parameter_group ? aws_rds_cluster_parameter_group.this[0].id : var.db_cluster_parameter_group_name
  #db_instance_parameter_group_name    = var.allow_major_version_upgrade ? var.db_cluster_db_instance_parameter_group_name : null
  db_subnet_group_name                = aws_db_subnet_group.this.name
  deletion_protection                 = false # var.deletion_protection
  # TODO enable_global_write_forwarding      = var.enable_global_write_forwarding
  # TODO enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  enable_http_endpoint                = false # var.enable_http_endpoint
  engine                              = var.db_engine
  engine_mode                         = "serverless"
  engine_version                      = var.db_engine_version
  final_snapshot_identifier           = var.skip_final_snapshot ? null : local.final_snapshot_id
  # global_cluster_identifier           = var.global_cluster_identifier
  # iam_database_authentication_enabled = var.iam_database_authentication_enabled
  # iam_roles has been removed from this resource and instead will be used with aws_rds_cluster_role_association below to avoid conflicts per docs
  # iops                          = var.iops
  kms_key_id                    = aws_kms_key.cmk.arn
  master_password               = random_password.db_password.result
  master_username               = local.db_master_user_name
  network_type                  = var.db_engine == "aurora-postgresql" ? "IPV4" : "DUAL"
  port                          = local.db_port
  # preferred_backup_window       = local.is_serverless ? null : var.preferred_backup_window
  # preferred_maintenance_window  = local.is_serverless ? null : var.preferred_maintenance_window
  # replication_source_identifier = var.replication_source_identifier

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 8 # TODO
    min_capacity             = var.db_engine == "aurora-postgresql" ? 2 : 1 # TODO
    seconds_until_auto_pause = 300 # TODO
    # TODO timeout_action           = try(scaling_configuration.value.timeout_action, null)
  }

  skip_final_snapshot    = var.skip_final_snapshot
  #snapshot_identifier    = var.snapshot_identifier
  #source_region          = var.source_region
  storage_encrypted      = true
  # storage_type           = var.storage_type
  tags                   = merge({
    Name = local.db_cluster_name
  }, local.module_common_tags)
  vpc_security_group_ids = [ aws_security_group.this.id ]
}