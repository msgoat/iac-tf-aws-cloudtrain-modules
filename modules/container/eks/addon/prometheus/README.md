# container/eks/addon/prometheus

Terraform module which deploys Prometheus based on Prometheus Operator using the 
upstream [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) 
Helm chart.

> Since this is an add-on this module only installs Prometheus without any ingresses.
> Grafana needs to be installed separately after an ingress controller is present on the cluster.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

## TODO's

| TODO                                                                                                              | Status | Last updated at |
|-------------------------------------------------------------------------------------------------------------------| --- |-----------------|
| Encrypt all persistent volumes                                                                                    | OPEN | 2022-04-12      |
