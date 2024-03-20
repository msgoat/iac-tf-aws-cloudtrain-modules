# container/eks/addon/aws-load-balancer-controller 

Terraform module to install the [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) on any given AWS EKS cluster.

By default, the AWS Load Balancer Controller is installed in Kubernetes namespace `aws-system` running with `2` replicas.

> __Deprecated__: Please use [ingress-aws](../ingress-aws/README.md) instead!!!

## Prerequisites

* Since the AWS Load Balancer Controller relies on [IAM roles for Kubernetes service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html), 
  an IAM OpenID Connect Provider must be present for the given EKS cluster.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

## References

@see [Installing the AWS Load Balancer Controller add-on](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)

@see [AWS Load Balancer Controller on GitHub](https://github.com/kubernetes-sigs/aws-load-balancer-controller)