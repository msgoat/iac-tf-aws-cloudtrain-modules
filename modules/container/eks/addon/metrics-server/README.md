# eks/addon/metrics-server 

Terraform module to install the [Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server) on any given AWS EKS cluster.

By default, the metrics server is installed in namespace `kube-system` running with `2` replicas.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)
