locals {
  autoscaler_values = <<EOT
replicas: 2

podDisruptionBudget:
  enabled: true
  maxUnavailable: 1

service:
  type: ClusterIP
  port: 443
  annotations: {}
  labels:
  #  Add these labels to have metrics-server show up in `kubectl cluster-info`
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "Metrics-server"

metrics:
  enabled: false

serviceMonitor:
  enabled: false
  additionalLabels: {}
  interval: 1m
  scrapeTimeout: 10s

resources: {}
EOT
}

resource "helm_release" "metrics_server" {
  chart             = "metrics-server"
  repository        = "https://kubernetes-sigs.github.io/metrics-server/"
  name              = "metrics-server"
  version           = "3.8.2"
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  namespace         = "kube-system"
  values            = [ local.autoscaler_values ]
}