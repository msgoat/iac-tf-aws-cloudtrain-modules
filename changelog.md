# Changelog
All notable changes to `iac-tf-aws-cloudtrain-modules` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - YYYY-MM-DD
### Added
### Changed
### Fixed

## [2.3.1] - 2023-12-21
### Fixed
- Module storage/blob: KMS key ID for customer managed encryption key is optional now

## [2.3.0] - 2023-11-28
### Added
- Added new module serverless/lambda

## [2.2.1] - 2023-11-15
### Changed
- Module container/eks/tool/logging/efk-eck-operator: fluent bit parses JSON formatted log messages correctly now
- Module container/eks/tool/monitoring/kube-prometheus-stack: prometheus detects service monitors outside of namespace monitoring correctly now

## [2.2.0] - 2023-11-06
### Changed
- Module container/eks/tool/monitoring/kube-prometheus-stack: upgraded helm chart version to 52.1.0 and app version to 0.68.0
- Module container/eks/tool/tracing/jaeger: upgraded helm chart version to 0.72.0 and app version to 1.51.0 
- Module container/eks/addon/cert-manager: upgraded helm chart version and app version to 1.13.2
- Module container/eks/addon/aws-load-balancer-controller: upgraded helm chart version to 1.6.2 and app version to 2.6.2
- Module container/eks/addon/cluster-autoscaler: upgraded helm chart version to 9.29.4 and app version to 1.27.2 

## [2.1.0] - 2023-11-03
### Changed
- Deprecated existing module container/eks/ingress/nginx and added new module container/eks/ingress/nginx2 as a replacement
- Deprecated existing module container/eks/ingress/nginx and added new module container/eks/ingress/nginx2 as a replacement
- Module container/eks/tool/eck-operator: upgraded Helm chart version to 2.9.0
- Module container/eks/tool/logging/efk-eck-operator: upgraded Fluent Bit to 2.1.10, Elasticsearch and Kibana to 8.10.4
- Minor documentation improvements

## [2.0.0] - 2023-10-31
### Changed
- upgraded to AWS provider 5.x

## [1.10.0] - 2023-07-31
### Added
- sonarqube scanner now breaks builds after quality gate failure

## [1.9.2] - 2023-07-25
### Added
- added proper module versioning through git tags
### Changed
- improved documentation in README.md
