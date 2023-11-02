# container/eks/ingress/nginx2 

> __Note:__
> Supersedes the former [container/eks/ingress/nginx](../nginx/README.md) module, which was hard to upgrade since it used a
> custom Helm chart depending on the upstream ingress-nginx helm chart. 
> This implementation works with two charts instead:
> * The upstream ingress-nginx helm chart
> * An internal custom helm chart named `nginx-aws-extensions` which add AWS-specific extensions missing in the upstream chart.
>
> Thus, upgrading the version of the upstream chart is fairly easy: just specify a newer version number via variable
> `helm_chart_version`.

Terraform module to install the [NGinX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) on any given AWS EKS cluster.

By default, the ingress controller is installed in namespace `ingress-nginx` running with `2` replicas 
spread across availability zones and nodes.

The following strategies are supported to expose the ingress controller outside the given EKS cluster:

* `SERVICE_VIA_NODE_PORT`: uses a service type __NodePort__ to expose the ingress controller endpoint
* `SERVICE_VIA_NLB`: uses a service type __LoadBalancer__ to expose the ingress controller endpoint via an AWS Network Load Balancer
* `INGRESS_VIA_ALB`: uses an ingress of ingress class __alb__ to expose the ingress controller endpoint via an AWS Application Load Balancer

> __Note__: This module assumes that NGinX is always receiving traffic which already passed through an AWS Application Loadbalancer.
> In order to keep NGinX from overwriting the `X-Forwarded-*` headers added by the AWS Application Loadbalancer, 
> the configuration parameter `use-forwarded-headers` is always set to *true*.

> __Note__: Since `OpenTelemetry` is the upcoming standard for tracing which will replace `OpenTracing`, this module only 
> activates support of OpenTelemetry by default. OpenTracing support is disabled.

## Prerequisites

* Both strategies `SERVICE_VIA_NLB` and `INGRESS_VIA_ALB` require the AWS Load Balancer Controller to be present on the given EKS cluster. 
* Both strategies `SERVICE_VIA_NLB` and `INGRESS_VIA_ALB` require a TLS certificate managed by AWS CM.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)
