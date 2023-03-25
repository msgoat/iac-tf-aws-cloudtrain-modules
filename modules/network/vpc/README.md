# modules/vpc: Terraform module to set up an AWS VPC

Creates a VPC spanning the given number of availability zones with the given stack of subnets per availability zone.

Each created subnet gets its own custom route table to avoid side-effects when changing shared route tables.

NAT gateways are added based on the chosen NAT strategy passed by variable `var.nat_strategy`:

* `NAT_NONE` : No NAT gateways are added to the VPC
* `NAT_GATEWAY_SINGLE` : A single NAT gateway is added to the first public subnet;
the outbound traffic of all private subnets leaving the VPC is routed through this single NAT gateway
* `NAT_GATEWAY_AZ` : One NAT gateway is added to the first public subnet of each availability zone; 
the outbound traffic from all private subnets leaving the VPC is routed 
through the NAT gateway in the same availability zone.
 
## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)
