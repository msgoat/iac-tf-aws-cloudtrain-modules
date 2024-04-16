output "default_cluster_issuer_name" {
  description = "Name of the default cluster issuer for TLS certificates"
  value       = "${helm_release.letsencrypt.name}-prod"
}

output "production_cluster_certificate_issuer_name" {
  description = "Name of the production cluster issuer for TLS certificates"
  value       = "${helm_release.letsencrypt.name}-prod"
}

output "test_cluster_certificate_issuer_name" {
  description = "Name of the test cluster issuer for TLS certificates"
  value       = "${helm_release.letsencrypt.name}-staging"
}