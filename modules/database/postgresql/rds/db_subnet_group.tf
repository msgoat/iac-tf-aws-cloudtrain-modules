locals {
  db_subnet_group_name = "sng-${var.region_name}-${var.solution_fqn}-${var.db_instance_name}"
}

resource aws_db_subnet_group postgresql {
  name = local.db_subnet_group_name
  description = "subnet group hosting PostgreSQL instance ${local.db_instance_name}"
  subnet_ids = var.db_subnet_ids
  tags = merge({
    Name = local.db_subnet_group_name
  }, local.module_common_tags)
}