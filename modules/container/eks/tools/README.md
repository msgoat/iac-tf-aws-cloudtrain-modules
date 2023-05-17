# container/eks/tools

Terraform module which installs an opinionated set of tool stacks on any given EKS cluster.

The opinionated set of tool stacks consists of:

* [kube-prometheus-stack](../tool/monitoring/kube-prometheus-stack/README.md) with Prometheus Operator and Grafana for `monitoring`
* [eck-operator](../tool/eck-operator/README.md) with Elastic Cloud Operator for Kubernetes to manage ElasticSearch clusters
* [logging](../tool/logging/efk/README.md) with ElasticSearch, FluentBit and Kibana for `logging`
* [tracing](../tool/tracing/jaeger/README.md) with ElasticSearch and Jaeger for `tracing`
