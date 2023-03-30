# container/eks/addon/aws-ebs-csi-driver 

Terraform module to install the [Amazon EBS CSI driver as an Amazon EKS add-on](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html) on any given AWS EKS cluster.

Additionally, this module adds 3 Kubernetes storage classes:

* `ebs-csi-gp2` provides GP2 volumes with default disk I/O settings and encryption using customer managed keys
* `ebs-csi-gp3` provides GP3 volumes with default disk I/O settings and encryption using customer managed keys
* `ebs-csi-gp3-premium` provides GP3 volumes with enhanced disk I/O settings and encryption using customer managed keys

The customer-managed key stored in AWS Key Management Service (KMS) is created by this module as well.

## Prerequisites

* Since the AWS EBS CSI driver relies on [IAM roles for Kubernetes service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html), 
  an IAM OpenID Connect Provider must be present for the given EKS cluster.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

## References

@see [Managing the Amazon EBS CSI driver as an Amazon EKS add-on](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html)
