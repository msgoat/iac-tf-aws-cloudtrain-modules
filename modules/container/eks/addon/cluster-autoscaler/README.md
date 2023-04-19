# container/eks/addon/cluster-autoscaler 

Terraform module to install the [Kubernetes Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) on any given AWS EKS cluster.

By default, the cluster autoscaler is installed in namespace `aws-system` running with `2` replicas.

## Prerequisites

* Since the cluster autoscaler relies on [IAM roles for Kubernetes service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html), 
  an IAM OpenID Connect Provider must be present for the given EKS cluster.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)
