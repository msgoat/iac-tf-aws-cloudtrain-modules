# container/eks/tools/ingress/certificates 

Terraform module to install default TLS certificates used by ingress controllers on any given AWS EKS cluster.

This module is only meant for ingress controller charts we do not control and which do not provide support for 
`cert-manager`'s `Certificate` CRDs.

## Prerequisites

* `cert-manager` must be present on the given EKS cluster.
* `LetsEncrypt` must be present as a cluster issuer on the given EKS cluster.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

## References
