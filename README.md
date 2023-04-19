# Terraform Module Libary iac-tf-aws-cloudtrain-modules

Terraform multi-module to manage cloud infrastructure on AWS.

Originally developed for msg's `Cloud Training Program` and `Cloud Expert Program`.

> Still work in progress! Provided AS IS without any warranties!

## Provided Terraform modules

Provides the following modules:

| Module Name                                                                                                            | Module Source                                            | Description                                                                                                                                                        |
|------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [container/eks/cluster](modules/container/eks/cluster/README.md)                                                       | modules/container/eks/cluster                            | Creates an AWS EKS cluster with EKS-managed node groups                                                                                                            | 
| [container/eks/addon/aws-ebs-csi-driver](modules/container/eks/addon/aws-ebs-csi-driver/README.md)                     | modules/container/eks/addon/aws-ebs-csi-driver           | Installs the [Amazon EBS CSI driver as an Amazon EKS add-on](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html) on any given AWS EKS cluster. | 
| [container/eks/addon/aws-load-balancer-controller](modules/container/eks/addon/aws-load-balancer-controller/README.md) | modules/container/eks/addon/aws-load-balancer-controller | Installs the [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) on any given AWS EKS cluster.      | 
| [container/eks/addon/cluster-autoscaler](modules/container/eks/addon/cluster-autoscaler/README.md)                     | modules/container/eks/addon/cluster-autoscaler           | Installs the [Kubernetes Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) on any given AWS EKS cluster.                | 
| [container/eks/addon/metrics-server](modules/container/eks/addon/metrics-server/README.md)                             | modules/container/eks/addon/metrics-server               | Installs the [Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server) on any given AWS EKS cluster.                                          | 
| [container/eks/tools/ingress/nginx](modules/container/eks/tools/ingress/nginx/README.md)                               | modules/container/eks/tools/ingress/nginx                | Installs the [NGinX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) on any given AWS EKS cluster.                                                 | 
| [container/eks/tools/ingress/traefik](modules/container/eks/tools/ingress/traefik/README.md)                           | modules/container/eks/tools/ingress/traefik              | Installs the Traefik Ingress Controller on any given AWS EKS cluster.                                                                                              | 
| [database/elasticsearch/eks](modules/database/elasticsearch/eks/README.md)                                             | modules/database/elasticsearch/eks                       | Provision an Elasticsearch cluster on any given AWS EKS cluster.                                                                                                   | 
| [database/postgresql/rds](modules/database/postgresql/rds/README.md)                                                   | modules/database/postgresql/rds                          | Provisions a PostgreSQL instance managed by AWS RDS.                                                                                                               | 
| [dns/hosted-zone](modules/dns/hosted-zone/README.md)                                                                   | modules/dns/hosted-zone                                  | Sets up a Route53 hosted zone.                                                                                                                                     | 
| [network/vpc](modules/network/vpc/README.md)                                                                           | modules/network/vpc                                      | Creates a VPC spanning the given number of availability zones with the given stack of subnets per availability zone.                                               | 
| [network/vpc-blueprint](modules/network/vpc-blueprint/README.md)                                                       | modules/network/vpc-blueprint                            | Creates a reference VPC based on a VPC blueprint.                                                                                                                  | 
| [security/certificate](modules/security/certificate/README.md)                                                         | modules/security/certificate                            | Creates a TLS certificate managed by AWS Certificate Manager.                                                                                                      | 
| [storage/blob](modules/storage/blob/README.md)                                                      | modules/storage/blob                            | Creates a S3 bucket supposed to be used for blob storage.                                                                                                          | 

## TODOs

