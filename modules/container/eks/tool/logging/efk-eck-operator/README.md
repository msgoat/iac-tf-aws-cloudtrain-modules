# container/eks/tool/logging/efk-eck-operator

Provisions a cluster tool stack for logging based on `Elasticsearch`, `Fluent Bit` and `Kibana` 
based on `Elastic Cloud Kubernetes Operator`.

## Prerequisites

* The Elastic Cloud Kubernetes Operator must be installed on the given AKS cluster 
(see Terraform module [container/tool/eck-operator](../../eck-operator/README.md)).