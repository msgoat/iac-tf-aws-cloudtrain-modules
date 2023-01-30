module postgresql {
  source = "../../../rds/postgresql"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = local.module_common_tags
  db_database_name = "keycloak"
  db_instance_name = "keycloak"
  vpc_id = data.aws_vpc.network.id
  eks_cluster_name = var.eks_cluster_name
}

data aws_vpc network {
  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}
