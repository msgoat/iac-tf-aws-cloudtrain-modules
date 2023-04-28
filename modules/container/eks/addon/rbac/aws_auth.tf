locals {
  aws_auth_value = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  labels:
    app.kubernetes.io/component: rbac
    app.kubernetes.io/instance: aws-auth
    app.kubernetes.io/managed-by: Terraform
    app.kubernetes.io/name: aws-auth
    app.kubernetes.io/part-of: ${var.solution_name}
  namespace: kube-system
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: ${local.node_role_arns[0]}
      username: system:node:{{EC2PrivateDNSName}}
    - groups:
      - system:masters
      rolearn: ${aws_iam_role.eks_admin.arn}
      username: eks-admin
%{ for r in data.aws_iam_role.given ~}
    - groups:
      - system:masters
      rolearn: ${r.arn}
      username: ${r.name}
%{ endfor ~}
YAML
}

resource kubectl_manifest aws_auth {
  yaml_body = local.aws_auth_value
  apply_only = true
}
