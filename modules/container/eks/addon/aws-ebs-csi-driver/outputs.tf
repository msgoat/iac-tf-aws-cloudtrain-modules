output "default_storage_class_id" {
  description = "Unique identifier of the default Kubernetes storage class"
  value       = kubernetes_storage_class_v1.ebs_csi_gp3.id
}

output "default_storage_class_name" {
  description = "Name of the default Kubernetes storage class"
  value       = kubernetes_storage_class_v1.ebs_csi_gp3.metadata[0].name
}

output "kubernetes_addon_id" {
  description = "Unique identifier of this cluster addon to define dependencies of downstream modules"
  value       = aws_eks_addon.aws_ebs_csi.id
}