# container/eks/addon/cert-manager 

Terraform module to install the [Kubernetes cert-manager](https://cert-manager.io/) on any given AWS EKS cluster.

By default, the AWS Load Balancer Controller is installed in Kubernetes namespace `cert-manager` running with `2` replicas.

## Prerequisites

* Since the Kubernetes cert-manager relies on [IAM roles for Kubernetes service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html), 
  an IAM OpenID Connect Provider must be present for the given EKS cluster.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

## References
