# eks/cluster 

Terraform module to setup an AWS EKS cluster with EKS-managed node groups.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

## TODOs

* Remove read of subnets hosting node groups since this may fail due to race conditions with module network/vpc
