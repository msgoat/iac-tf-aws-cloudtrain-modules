# container/eks/tool/logging/efk

Terraform module which installs a classic EFK-stack on any given EKS cluster.

The classic EFK-stack consists of:

* `ElasticSearch` as a datastore for log events
* `FluentBit` as a collector and aggregator of log events
* `Kibana` as an user interface to query and analyse log events