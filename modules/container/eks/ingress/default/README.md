# container/eks/ingress/default 

Terraform module to install any ingress controller on the given AWS EKS cluster plus
an AWS Application Load Balancer forwarding traffic to the ingress controller.

Supported ingress controller types are:

* `NGINX`
* ...

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)
