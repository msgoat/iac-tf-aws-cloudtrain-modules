output "default_storage_class_id" {
  description = "Unique identifier of the default Kubernetes storage class"
  value       = kubernetes_storage_class_v1.ebs_csi_gp3.id
}

output "default_storage_class_name" {
  description = "Name of the default Kubernetes storage class"
  value       = kubernetes_storage_class_v1.ebs_csi_gp3.metadata[0].name
}