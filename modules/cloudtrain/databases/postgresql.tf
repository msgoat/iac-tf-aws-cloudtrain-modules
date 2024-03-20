# provisions a common postgres instance for all showcases

module "postgres" {
  source = "../../database/postgresql/rds"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = local.module_common_tags
  db_instance_name = "cloudtrain"
  db_database_name = "cloudtrain"
  db_subnet_ids = var.db_subnet_ids
  vpc_id = var.vpc_id
}