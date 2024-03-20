# container/eks/addons 

Terraform module to install an opinionated set of Kubernetes cluster add-ons on any given AWS EKS cluster.

Currently,  the following add-ons are supported:

* [AWS EKS RBAC](../addon/rbac/README.md) to manage admin role bindings using AWS IAM identities
* [AWS EBS CSI Driver Add-On](../addon/aws-ebs-csi-driver/README.md) to add additional storage options like CMK-encrypted EBS volumes
* [Kubernetes Metrics Server](../addon/metrics-server/README.md) to add basic metrics support
* [Kubernetes Cluster Auto Scaler](../addon/cluster-autoscaler/README.md) to add elasticity to the cluster
* [Kubernetes Certificate Manager](../addon/cert-manager/README.md) to managed TLS certificates using LetsEncrypt as certificate issuer
* [AWS Load Balancer Controller](../addon/ingress-aws/README.md) to expose services directly via a load balancer in front of the cluster
* [NGinX Ingress Controller](../addon/ingress-nginx/README.md) to expose services via NGinX
* [Elastic Cloud Kubernetes Operator](../addon/eck-operator/README.md) to manage products like ElasticSearch and Kibana

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

## References
