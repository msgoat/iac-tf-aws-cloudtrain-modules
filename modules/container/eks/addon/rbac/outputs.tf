output aws_auth_config_map {
  description = "Kubernetes manifest representing the aws-auth ConfigMap"
  value = local.aws_auth_value
}

output eks_admin_role_name {
  description = "Name of the IAM role which allows access to this specific clusters to all IAM users and some AWS services"
  value = aws_iam_role.eks_admin.name
}

output eks_admin_role_arn {
  description = "ARN of the IAM role which allows access to this specific clusters to all IAM users and some AWS services"
  value = aws_iam_role.eks_admin.arn
}