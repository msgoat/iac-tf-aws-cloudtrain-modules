# Terraform Module Libary iac-tf-aws-cloudtrain-modules

Terraform multi-module to manage cloud infrastructure on AWS.

Originally developed for msg's `Cloud Training Program` and `Cloud Expert Program`.

> Still work in progress! Provided AS IS without any warranties!

## Module Versioning

This terraform multi-module is versioning via git tags. The main revision number according to semantic versioning 
is stored in file [revision.txt](revision.txt). During the build further parts like branch name and short commit hash
are added to the tag name as well.

So if revision is `1.1.1` and the branch is `main` and the short commit hash is `12345678` the git tag name is `1.1.1.main.12345678`.

Whenever you want to pin the module version used in your terraform live code to a specific version 
like `1.1.1.main.12345678`, add the corresponding tag name to the modules `source` attribute:

```text
module "eks_cluster" {
    source = "git::https://github.com/msgoat/iac-tf-aws-cloudtrain-modules.git//modules/container/eks/cluster?ref=1.1.1.main.12345678"
}
```

## Release Information

A changelog can be found in [changelog.md](changelog.md).

## Status

![Build status](https://codebuild.eu-west-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiaVVHN0Z6b2srYkV5K3lOYVRYbDhDa1FXMlRYWGZ3NnBmYUI0UlczYzVDVXFzei9VTVA1dFI2YjZwbXZGcEtzNE9FMWthaGlpVmo3T3pCdXZJNmNZQnVjPSIsIml2UGFyYW1ldGVyU3BlYyI6IkhvSENJbGYrdHE0NlZRdnEiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=main)

## Provided Terraform modules

Provides the following modules:

| Module Name                                                                                                            | Module Source                                                  | Description                                                                                                                                                        |
|------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [container/eks/cluster](modules/container/eks/cluster/README.md)                                                       | modules/container/eks/cluster                                  | Creates an AWS EKS cluster with EKS-managed node groups                                                                                                            | 
| [container/eks/addon/aws-ebs-csi-driver](modules/container/eks/addon/aws-ebs-csi-driver/README.md)                     | modules/container/eks/addon/aws-ebs-csi-driver                 | Installs the [Amazon EBS CSI driver as an Amazon EKS add-on](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html) on any given AWS EKS cluster. | 
| [container/eks/addon/aws-load-balancer-controller](modules/container/eks/addon/aws-load-balancer-controller/README.md) | modules/container/eks/addon/aws-load-balancer-controller       | Installs the [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) on any given AWS EKS cluster.      | 
| [container/eks/addon/cluster-autoscaler](modules/container/eks/addon/cluster-autoscaler/README.md)                     | modules/container/eks/addon/cluster-autoscaler                 | Installs the [Kubernetes Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) on any given AWS EKS cluster.                | 
| [container/eks/addon/metrics-server](modules/container/eks/addon/metrics-server/README.md)                             | modules/container/eks/addon/metrics-server                     | Installs the [Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server) on any given AWS EKS cluster.                                          | 
| [container/eks/ingress/default](modules/container/eks/ingress/default/README.md)                                       | modules/container/eks/ingress/default                          | Provisions an ingress controller on the given AWS EKS cluster plus an AWS Application Load Balancer forwarding traffic to the ingress controller.          | 
| [container/eks/ingress/nginx](modules/container/eks/ingress/nginx/README.md)                                           | modules/container/eks/ingress/nginx                            | Installs the [NGinX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) on any given AWS EKS cluster.                                                 | 
| [container/eks/ingress/traefik](modules/container/eks/ingress/traefik/README.md)                                       | modules/container/eks/ingress/traefik                          | Installs the Traefik Ingress Controller on any given AWS EKS cluster.                                                                                              | 
| [container/eks/tool/eks-operator](modules/container/eks/tool/eks-operator/README.md)                                   | modules/container/tool/eks-operator                          | Provisions the [Elastic Cloud Kubernetes Operator](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-overview.html) on the given EKS cluster. | 
| [container/eks/tool/monitoring/kube-prometheus-stack](modulescontainer/eks/tool/monitoring/kube-prometheus-stack/README.md)   | modules/container/eks/tool/monitoring/kube-prometheus-stack                          | deploys a cluster monitoring stack based on Prometheus Operator using the upstream [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) Helm chart. | 
| [database/elasticsearch/eks](modules/database/elasticsearch/eks/README.md)                                             | modules/database/elasticsearch/eks                             | Provision an Elasticsearch cluster on any given AWS EKS cluster.                                                                                                   | 
| [database/postgresql/rds](modules/database/postgresql/rds/README.md)                                                   | modules/database/postgresql/rds                                | Provisions a PostgreSQL instance managed by AWS RDS.                                                                                                               | 
| [dns/hosted-zone](modules/dns/hosted-zone/README.md)                                                                   | modules/dns/hosted-zone                                        | Sets up a Route53 hosted zone.                                                                                                                                     | 
| [network/vpc](modules/network/vpc/README.md)                                                                           | modules/network/vpc                                            | Creates a VPC spanning the given number of availability zones with the given stack of subnets per availability zone.                                               | 
| [network/vpc-blueprint](modules/network/vpc-blueprint/README.md)                                                       | modules/network/vpc-blueprint                                  | Creates a reference VPC based on a VPC blueprint.                                                                                                                  | 
| [security/certificate](modules/security/certificate/README.md)                                                         | modules/security/certificate                                   | Creates a TLS certificate managed by AWS Certificate Manager.                                                                                                      | 
| [storage/blob](modules/storage/blob/README.md)                                                                         | modules/storage/blob                                           | Creates a S3 bucket supposed to be used for blob storage.                                                                                                          | 
