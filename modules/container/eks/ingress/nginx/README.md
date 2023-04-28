# container/eks/ingress/nginx 

Terraform module to install the [NGinX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) on any given AWS EKS cluster.

By default, the ingress controller is installed in namespace `ingress-nginx` running with `2` replicas.

The following strategies are supported to expose the ingress controller outside the given EKS cluster:

* `SERVICE_VIA_NODE_PORT`: uses a service type __NodePort__ to expose the ingress controller endpoint
* `SERVICE_VIA_NLB`: uses a service type __LoadBalancer__ to expose the ingress controller endpoint via an AWS Network Load Balancer
* `INGRESS_VIA_ALB`: uses an ingress of ingress class __alb__ to expose the ingress controller endpoint via an AWS Application Load Balancer

## Prerequisites

* Both strategies `SERVICE_VIA_NLB` and `INGRESS_VIA_ALB` require the AWS Load Balancer Controller to be present on the given EKS cluster. 
* Both strategies `SERVICE_VIA_NLB` and `INGRESS_VIA_ALB` require a TLS certificate managed by AWS CM.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)
