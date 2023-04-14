# container/eks/cluster 

Terraform module to setup an AWS EKS cluster with EKS-managed node groups.

Additionally, this module creates an associated OpenID Connect Provider for the AWS EKS cluster.

Managed EKS node groups are created based on the given `node_group_templates`. 

How the node groups are distributed across the given subnet is defined by `node_group_strategy`:

* `SINGLE_MULTI_AZ`: Each given template creates a single node group spanning all given subnets.
* `MULTI_SINGLE_AZ`: Each given template creates multiple node groups, one for each given subnet.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

