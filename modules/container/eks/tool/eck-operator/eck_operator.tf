locals {
  actual_replica_count = var.ensure_high_availability && var.replica_count < 2 ? 2 : var.replica_count
  # render helm chart values since direct passing of values does not work in all cases
  eck_values = <<EOT
nameOverride: ""
fullnameOverride: ""

managedNamespaces: []

installCRDs: true

replicaCount: ${local.actual_replica_count}

priorityClassName: ""

resources:
  limits:
    cpu: 1
    memory: 1Gi
  requests:
    cpu: 100m
    memory: 150Mi

podAnnotations: {}
podLabels: {}

podSecurityContext:
  runAsNonRoot: true

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true

nodeSelector: {}

%{ if var.node_group_workload_class != "" ~}
# It's OK to be deployed to the tools pool, too
tolerations:
  - key: "group.msg.cloud.kubernetes/workload"
    operator: "Equal"
    value: ${var.node_group_workload_class}
    effect: "NoSchedule"
%{ endif ~}
%{ if var.node_group_workload_class != "" ~}
affinity:
  # Encourages deployment to the tools pool
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: "group.msg.cloud.kubernetes/workload"
              operator: In
              values:
                - ${var.node_group_workload_class}
%{ endif ~}
%{ if var.ensure_high_availability ~}
topologySpreadConstraints:
  - labelSelector:
      matchLabels:
        app.kubernetes.io/name: '{{ include "eck-operator" . }}'
        app.kubernetes.io/instance: '{{ .Release.Name }}'
    topologyKey: topology.kubernetes.io/zone
    maxSkew: 1
    whenUnsatisfiable: ScheduleAnyway
  - labelSelector:
      matchLabels:
        app.kubernetes.io/name: '{{ include "eck-operator" . }}'
        app.kubernetes.io/instance: '{{ .Release.Name }}'
    topologyKey: kubernetes.io/hostname
    maxSkew: 1
    whenUnsatisfiable: ScheduleAnyway
%{ else ~}
  topologySpreadConstraints: []
%{ endif ~}

env: []
volumeMounts: []
volumes: []

createClusterScopedResources: true

serviceAccount:
  create: true
  annotations: {}
  name: ""

tracing:
  enabled: false

refs:
  enforceRBAC: false

webhook:
  enabled: true
  # caBundle is the PEM-encoded CA trust bundle for the webhook certificate. Only required if manageCerts is false and certManagerCert is null.
  caBundle: Cg==
  # certManagerCert is the name of the cert-manager certificate to use with the webhook.
  certManagerCert: null
  # certsDir is the directory to mount the certificates.
  certsDir: "/tmp/k8s-webhook-server/serving-certs"
  # failurePolicy of the webhook.
  failurePolicy: Ignore
  # manageCerts determines whether the operator manages the webhook certificates automatically.
  manageCerts: true
  # namespaceSelector corresponds to the namespaceSelector property of the webhook.
  # Setting this restricts the webhook to act only on objects submitted to namespaces that match the selector.
  namespaceSelector: {}
  # objectSelector corresponds to the objectSelector property of the webhook.
  # Setting this restricts the webhook to act only on objects that match the selector.
  objectSelector: {}

softMultiTenancy:
  enabled: false

kubeAPIServerIP: null

telemetry:
  disabled: false
  distributionChannel: "helm"

config:
  logVerbosity: "0"
  metricsPort: "0"
  # containerSuffix: ""
  maxConcurrentReconciles: "3"
  caValidity: 8760h
  caRotateBefore: 24h
  certificatesValidity: 8760h
  certificatesRotateBefore: 24h
  exposedNodeLabels: [ "topology.kubernetes.io/.*", "failure-domain.beta.kubernetes.io/.*" ]
  setDefaultSecurityContext: "auto-detect"
  kubeClientTimeout: 60s
  elasticsearchClientTimeout: 180s
  validateStorageClass: true
  enableLeaderElection: true
  elasticsearchObservationInterval: 10s

podMonitor:
  enabled: false
  labels: {}
  annotations: {}
  # namespace: monitoring
  interval: 5m
  scrapeTimeout: 30s
  podTargetLabels: []
  podMetricsEndpointConfig: {}
  # honorTimestamps: true

# Globals meant for internal use only
global:
  manifestGen: false
  createOperatorNamespace: true
  kubeVersion: 1.21.0
EOT
}

resource helm_release eck {
  chart = "eck-operator"
  version = var.helm_chart_version
  repository = "https://helm.elastic.co"
  name = var.helm_release_name
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  namespace = kubernetes_namespace_v1.elastic.metadata[0].name
  create_namespace = false
  values = [ local.eck_values ]
}