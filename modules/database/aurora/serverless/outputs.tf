output db_cluster_id {
  description = "Unique identifier of the DB cluster"
  value = aws_rds_cluster.this.id
}

output db_cluster_host {
  description = "Hostname of the DB cluster endpoint"
  value = aws_rds_cluster.this.endpoint
}

output db_cluster_port {
  description = "Port number of the DB cluster endpoint"
  value = aws_rds_cluster.this.port
}
