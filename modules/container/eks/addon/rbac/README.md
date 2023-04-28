# container/eks/addon/rbac 

Terraform module to setup proper AWS RBAC on a given AWS EKS cluster by changing the `aws-auth` config map.

Creates a dedicated IAM role specifically for the given AWS EKS cluster which any user in the same AWS account 
and some selected services like AWS CodeBuild may assume. This dedicated IAM role solves the problem that only 
the IAM principal which creates the AWS EKS cluster is allowed to access the cluster by default.

The ARN of the dedicated IAM role must be passed to the `aws eks update-kubeconfig` command 
when obtaining a kubeconfig file for the given AWS EKS cluster.

Optionally, all given IAM roles are added as `system:masters` to the `aws-auth` config map as well. This allows
global admins to access all AWS EKS clusters.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

