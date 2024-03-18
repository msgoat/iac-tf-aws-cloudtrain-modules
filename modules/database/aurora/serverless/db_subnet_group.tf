locals {
  db_subnet_group_name = "sng-${local.db_cluster_name}"
}

resource aws_db_subnet_group this {
  name = local.db_subnet_group_name
  description = "subnet group hosting Aurora cluster ${local.db_cluster_name}"
  subnet_ids = var.db_subnet_ids
  tags = merge({
    Name = local.db_subnet_group_name
  }, local.module_common_tags)
}