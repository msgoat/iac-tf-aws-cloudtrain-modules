# container/eks/addon/grafana

Terraform module which deploys [Grafana](https://grafana.com/grafana/) as part of a cluster monitoring stack 
using the upstream [grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana) 
Helm chart.

## Dependencies

* Terraform module [container/eks/addon/prometheus](../prometheus/README.md)

## Prerequisites

* Expects at least one ingress controller like [ingress-nginx](../ingress-nginx/README.md) to be present

## Input Variables

see: [variables.tf](variables.tf)

## Outputs

see: [outputs.tf](outputs.tf)

## TODO's

| TODO                                                                                                              | Status | Last updated at |
|-------------------------------------------------------------------------------------------------------------------| --- |-----------------|
| Encrypt all persistent volumes                                                                                    | OPEN | 2022-04-12      |
