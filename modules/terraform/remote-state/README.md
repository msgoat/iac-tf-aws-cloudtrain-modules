# Terraform Module terraform/remote-state 

Terraform module to set up a Terraform remote backend based on S3 and DynamoDB.

Creates a S3 bucket for state storage and a DynamoDB table for state locking.

> This module tries to be as compliant as possible with CSI benchmarks and AWS best practices.
 
## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

