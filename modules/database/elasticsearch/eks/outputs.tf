output elasticsearch_service_name {
  description = "Name of the Kubernetes service representing the ElasticSearch cluster"
  value = "${var.elasticsearch_cluster_name}-master"
}

output elasticsearch_service_port {
  description = "Port number of the Kubernetes service representing the ElasticSearch cluster"
  value = "9200"
}