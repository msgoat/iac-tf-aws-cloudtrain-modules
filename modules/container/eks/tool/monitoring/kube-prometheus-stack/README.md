# eks/tools/monitoring/kube-prometheus-stack

Terraform module which deploys a cluster monitoring stack based on Prometheus Operator using the 
upstream [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) 
Helm chart.

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

## TODO's

| TODO                                                                                                              | Status | Last updated at |
|-------------------------------------------------------------------------------------------------------------------| --- |-----------------|
| Encrypt all persistent volumes                                                                                    | OPEN | 2022-04-12      |
