data aws_iam_role given {
  for_each = toset(var.eks_cluster_admin_role_names)
  name = each.value
}
