locals {
  helm_chart_name   = "cluster-autoscaler"
  autoscaler_values = <<EOT
replicaCount: 2
autoDiscovery:
  clusterName: ${var.eks_cluster_name}

# awsRegion -- AWS region (required if `cloudProvider=aws`)
awsRegion: ${var.region_name}

# cloudProvider -- The cloud provider where the autoscaler runs.
cloudProvider: aws

# containerSecurityContext -- [Security context for container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
containerSecurityContext:
  capabilities:
    drop:
    - ALL

# extraArgs -- Additional container arguments.
# Refer to https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca for the full list of cluster autoscaler
# parameters and their default values.
# Everything after the first _ will be ignored allowing the use of multi-string arguments.
extraArgs:
  logtostderr: true
  stderrthreshold: info
  v: 4
  # write-status-configmap: true
  # status-config-map-name: cluster-autoscaler-status
  # leader-elect: true
  # leader-elect-resource-lock: endpoints
  # skip-nodes-with-local-storage: true
  # expander: random
  # scale-down-enabled: true
  balance-similar-node-groups: true
  # min-replica-count: 0
  # scale-down-utilization-threshold: 0.5
  # scale-down-non-empty-candidates-count: 30
  # max-node-provision-time: 15m0s
  # scan-interval: 10s
  # scale-down-delay-after-add: 10m
  # scale-down-delay-after-delete: 0s
  # scale-down-delay-after-failure: 3m
  # scale-down-unneeded-time: 10m
  skip-nodes-with-system-pods: false
  # balancing-ignore-label_1: first-label-to-ignore
  # balancing-ignore-label_2: second-label-to-ignore

rbac:
  # rbac.create -- If `true`, create and use RBAC resources.
  create: true
  # rbac.pspEnabled -- If `true`, creates and uses RBAC resources required in the cluster with [Pod Security Policies](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) enabled.
  # Must be used with `rbac.create` set to `true`.
  pspEnabled: false
  # rbac.clusterScoped -- if set to false will only provision RBAC to alter resources in the current namespace. Most useful for Cluster-API
  clusterScoped: true
  serviceAccount:
    # rbac.serviceAccount.annotations -- Additional Service Account annotations.
    annotations:
      eks.amazonaws.com/role-arn: "${aws_iam_role.cluster_autoscaler.arn}"
    # rbac.serviceAccount.create -- If `true` and `rbac.create` is also true, a Service Account will be created.
    create: true
    # rbac.serviceAccount.name -- The name of the ServiceAccount to use. If not set and create is `true`, a name is generated using the fullname template.
    name: ""
    # rbac.serviceAccount.automountServiceAccountToken -- Automount API credentials for a Service Account.
    automountServiceAccountToken: true

# resources -- Pod resource requests and limits.
resources:
  limits:
    cpu: 100m
    memory: 300Mi
  requests:
    cpu: 100m
    memory: 300Mi

# securityContext -- [Security context for pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  runAsGroup: 1001

## Are you using Prometheus Operator?
serviceMonitor:
  # serviceMonitor.enabled -- If true, creates a Prometheus Operator ServiceMonitor.
  enabled: false
  # serviceMonitor.interval -- Interval that Prometheus scrapes Cluster Autoscaler metrics.
  interval: 10s
  # serviceMonitor.namespace -- Namespace which Prometheus is running in.
  namespace: monitoring
  ## [Prometheus Selector Label](https://github.com/helm/charts/tree/master/stable/prometheus-operator#prometheus-operator-1)
  ## [Kube Prometheus Selector Label](https://github.com/helm/charts/tree/master/stable/prometheus-operator#exporters)
  # serviceMonitor.selector -- Default to kube-prometheus install (CoreOS recommended), but should be set according to Prometheus install.
  selector:
    release: prometheus-operator
  # serviceMonitor.path -- The path to scrape for metrics; autoscaler exposes `/metrics` (this is standard)
  path: /metrics

%{if var.ensure_high_availability~}
topologySpreadConstraints:
- labelSelector:
    matchLabels:
      app.kubernetes.io/name: ${var.helm_release_name}
      app.kubernetes.io/instance: ${var.helm_release_name}
  topologyKey: topology.kubernetes.io/zone
  maxSkew: 1
  whenUnsatisfiable: ScheduleAnyway
- labelSelector:
    matchLabels:
      app.kubernetes.io/name: ${var.helm_release_name}
      app.kubernetes.io/instance: ${var.helm_release_name}
  topologyKey: kubernetes.io/hostname
  maxSkew: 1
  whenUnsatisfiable: ScheduleAnyway
%{else~}
topologySpreadConstraints: []
%{endif~}
EOT
}

resource "helm_release" "autoscaler" {
  chart             = local.helm_chart_name
  repository        = "https://kubernetes.github.io/autoscaler"
  name              = var.helm_release_name
  version           = var.helm_chart_version
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  namespace         = var.kubernetes_namespace_name
  create_namespace  = true
  values            = [local.autoscaler_values]
  depends_on        = [aws_iam_role_policy.cluster_autoscaler]
}