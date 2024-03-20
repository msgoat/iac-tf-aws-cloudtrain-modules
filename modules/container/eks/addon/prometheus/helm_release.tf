locals {
  actual_replica_count = var.ensure_high_availability ? 2 : var.replica_count
  prometheus_stack_values = <<EOT
# Custom values for kube-prometheus-stack.
# The default values can be found at: https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md
nameOverride: ${var.helm_release_name}
namespaceOverride: ""
fullnameOverride: ""

commonLabels: {}

defaultRules:
  create: true
  rules:
    alertmanager: true
    etcd: true
    configReloaders: true
    general: true
    k8s: true
    kubeApiserverAvailability: true
    kubeApiserverBurnrate: true
    kubeApiserverHistogram: true
    kubeApiserverSlos: true
    kubeControllerManager: true
    kubelet: true
    kubeProxy: true
    kubePrometheusGeneral: true
    kubePrometheusNodeRecording: true
    kubernetesApps: true
    kubernetesResources: true
    kubernetesStorage: true
    kubernetesSystem: true
    kubeSchedulerAlerting: true
    kubeSchedulerRecording: true
    kubeStateMetrics: true
    network: true
    node: true
    nodeExporterAlerting: true
    nodeExporterRecording: true
    prometheus: true
    prometheusOperator: true
  appNamespacesTarget: ".*"
  labels: {}
  annotations: {}
  additionalRuleLabels: {}
  additionalRuleAnnotations: {}
  runbookUrl: "https://runbooks.prometheus-operator.dev/runbooks"
  disabled: {}

global:
  rbac:
    create: true

alertmanager:
  enabled: ${var.alert_manager_enabled}
%{ if var.alert_manager_enabled ~}
  annotations: {}
  apiVersion: v2
  serviceAccount:
    create: true
  podDisruptionBudget:
    enabled: ${local.actual_replica_count > 1 ? true : false}
    minAvailable: 1
  stringConfig: ""
  tplConfig: false
  templateFiles: {}
  ingress:
    enabled: false
  secret:
    annotations: {}
  service:
    annotations: {}
    labels: {}
    type: ClusterIP
  serviceMonitor:
    interval: ""
    selfMonitor: true
    additionalLabels: {}
    sampleLimit: 0
    targetLimit: 0
    labelLimit: 0
    labelNameLengthLimit: 0
    labelValueLengthLimit: 0
    proxyUrl: ""
    scheme: ""
    enableHttp2: true
    tlsConfig: {}
    bearerTokenFile:
    metricRelabelings: []
    relabelings: []
  alertmanagerSpec:
    podMetadata: {}
    useExistingSecret: false
    secrets: []
    configMaps: []
    # configSecret:
    web: {}
    alertmanagerConfigSelector: {}
    alertmanagerConfigNamespaceSelector: {}
    alertmanagerConfiguration: {}
    alertmanagerConfigMatcherStrategy: {}
    logFormat: json
    logLevel: info
    replicas: ${local.actual_replica_count}
    retention: 120h
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: ${var.kubernetes_storage_class_name}
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: "${var.alert_manager_storage_size}Gi"
    externalUrl: ""
    routePrefix: /
    paused: false
    nodeSelector: {}
    resources: {} # TODO: add resource constraints
    podAntiAffinity: ""
    podAntiAffinityTopologyKey: kubernetes.io/hostname
    affinity: {}
    tolerations: []
    topologySpreadConstraints: []
    securityContext:
      runAsGroup: 2000
      runAsNonRoot: true
      runAsUser: 1000
      fsGroup: 2000
    listenLocal: false
    containers: []
    volumes: []
    volumeMounts: []
    initContainers: []
    priorityClassName: ""
    additionalPeers: []
    portName: "http-web"
    clusterAdvertiseAddress: false
    forceEnableClusterMode: false
    minReadySeconds: 0
  extraSecret:
    # name: ""
    annotations: {}
    data: {}
%{ endif ~}

grafana:
  enabled: false

kubernetesServiceMonitors:
  enabled: true
kubeApiServer:
  enabled: true
  tlsConfig:
    serverName: kubernetes
    insecureSkipVerify: false
  serviceMonitor:
    interval: ""
    sampleLimit: 0
    targetLimit: 0
    labelLimit: 0
    labelNameLengthLimit: 0
    labelValueLengthLimit: 0
    proxyUrl: ""
    jobLabel: component
    selector:
      matchLabels:
        component: apiserver
        provider: kubernetes
    metricRelabelings:
      # Drop excessively noisy apiserver buckets.
      - action: drop
        regex: apiserver_request_duration_seconds_bucket;(0.15|0.2|0.3|0.35|0.4|0.45|0.6|0.7|0.8|0.9|1.25|1.5|1.75|2|3|3.5|4|4.5|6|7|8|9|15|25|40|50)
        sourceLabels:
          - __name__
          - le
    relabelings: []
    additionalLabels: {}

kubelet:
  enabled: true
  namespace: kube-system
  serviceMonitor:
    interval: ""
    sampleLimit: 0
    targetLimit: 0
    labelLimit: 0
    labelNameLengthLimit: 0
    labelValueLengthLimit: 0
    proxyUrl: ""
    https: true
    cAdvisor: true
    probes: true
    resource: false
    resourcePath: "/metrics/resource/v1alpha1"
    cAdvisorMetricRelabelings:
      # Drop less useful container CPU metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_cpu_(cfs_throttled_seconds_total|load_average_10s|system_seconds_total|user_seconds_total)'
      # Drop less useful container / always zero filesystem metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_fs_(io_current|io_time_seconds_total|io_time_weighted_seconds_total|reads_merged_total|sector_reads_total|sector_writes_total|writes_merged_total)'
      # Drop less useful / always zero container memory metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_memory_(mapped_file|swap)'
      # Drop less useful container process metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_(file_descriptors|tasks_state|threads_max)'
      # Drop container spec metrics that overlap with kube-state-metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: 'container_spec.*'
      # Drop cgroup metrics with no pod.
      - sourceLabels: [id, pod]
        action: drop
        regex: '.+;'
    probesMetricRelabelings: []
    cAdvisorRelabelings:
      - action: replace
        sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    probesRelabelings:
      - action: replace
        sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    resourceRelabelings:
      - action: replace
        sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    metricRelabelings: []
    relabelings:
      - action: replace
        sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    additionalLabels: {}

kubeControllerManager:
  enabled: true
  endpoints: []
  service:
    enabled: true
    port: null
    targetPort: null
    # selector:
    #   component: kube-controller-manager
  serviceMonitor:
    enabled: true
    interval: ""
    sampleLimit: 0
    targetLimit: 0
    labelLimit: 0
    labelNameLengthLimit: 0
    labelValueLengthLimit: 0
    proxyUrl: ""
    https: null
    insecureSkipVerify: null
    serverName: null
    metricRelabelings: []
    relabelings: []
    additionalLabels: {}

coreDns:
  enabled: true
  service:
    port: 9153
    targetPort: 9153
    # selector:
    #   k8s-app: kube-dns
  serviceMonitor:
    interval: ""
    sampleLimit: 0
    targetLimit: 0
    labelLimit: 0
    labelNameLengthLimit: 0
    labelValueLengthLimit: 0
    proxyUrl: ""
    metricRelabelings: []
    relabelings: []
    additionalLabels: {}

kubeDns:
  enabled: false

kubeEtcd:
  enabled: true
  endpoints: []
  service:
    enabled: true
    port: 2381
    targetPort: 2381
    # selector:
    #   component: etcd

  ## serviceMonitor:
  ##   scheme: https
  ##   insecureSkipVerify: false
  ##   serverName: localhost
  ##   caFile: /etc/prometheus/secrets/etcd-client-cert/etcd-ca
  ##   certFile: /etc/prometheus/secrets/etcd-client-cert/etcd-client
  ##   keyFile: /etc/prometheus/secrets/etcd-client-cert/etcd-client-key
  ##
  serviceMonitor:
    enabled: true
    interval: ""
    sampleLimit: 0
    targetLimit: 0
    labelLimit: 0
    labelNameLengthLimit: 0
    labelValueLengthLimit: 0
    proxyUrl: ""
    scheme: http
    insecureSkipVerify: false
    serverName: ""
    caFile: ""
    certFile: ""
    keyFile: ""
    metricRelabelings: []
    relabelings: []
    additionalLabels: {}

kubeScheduler:
  enabled: true
  endpoints: []
  service:
    enabled: true
    port: null
    targetPort: null
    # selector:
    #   component: kube-scheduler
  serviceMonitor:
    enabled: true
    interval: ""
    sampleLimit: 0
    targetLimit: 0
    labelLimit: 0
    labelNameLengthLimit: 0
    labelValueLengthLimit: 0
    proxyUrl: ""
    https: null
    insecureSkipVerify: null
    serverName: null
    metricRelabelings: []
    relabelings: []
    additionalLabels: {}

kubeProxy:
  enabled: true
  endpoints: []
  service:
    enabled: true
    port: 10249
    targetPort: 10249
    # selector:
    #   k8s-app: kube-proxy
  serviceMonitor:
    enabled: true
    interval: ""
    sampleLimit: 0
    targetLimit: 0
    labelLimit: 0
    labelNameLengthLimit: 0
    labelValueLengthLimit: 0
    proxyUrl: ""
    https: false
    metricRelabelings: []
    relabelings: []
    additionalLabels: {}

kubeStateMetrics:
  enabled: true

kube-state-metrics:
  namespaceOverride: ""
  rbac:
    create: true
  releaseLabel: true
  prometheus:
    monitor:
      enabled: true
      interval: ""
      sampleLimit: 0
      targetLimit: 0
      labelLimit: 0
      labelNameLengthLimit: 0
      labelValueLengthLimit: 0
      scrapeTimeout: ""
      proxyUrl: ""
      honorLabels: true
      metricRelabelings: []
      relabelings: []
  selfMonitor:
    enabled: false

nodeExporter:
  enabled: true

prometheus-node-exporter:
  namespaceOverride: ""
  podLabels:
    jobLabel: node-exporter
  releaseLabel: true
  extraArgs:
    - --collector.filesystem.mount-points-exclude=^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/.+)($|/)
    - --collector.filesystem.fs-types-exclude=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$
  service:
    portName: http-metrics
  prometheus:
    monitor:
      enabled: true
      jobLabel: jobLabel
      interval: ""
      sampleLimit: 0
      targetLimit: 0
      labelLimit: 0
      labelNameLengthLimit: 0
      labelValueLengthLimit: 0
      scrapeTimeout: ""
      proxyUrl: ""
      metricRelabelings: []
      relabelings: []
  rbac:
    pspEnabled: false

prometheusOperator:
  enabled: true
  tls:
    enabled: true
    tlsMinVersion: VersionTLS13
    internalPort: 10250
  admissionWebhooks:
    failurePolicy:
    timeoutSeconds: 10
    enabled: true
    caBundle: ""
    annotations: {}
    patch:
      enabled: true
      resources: {}
      priorityClassName: ""
      annotations: {}
      podAnnotations: {}
      nodeSelector: {}
      affinity: {}
      tolerations: []
      securityContext:
        runAsGroup: 2000
        runAsNonRoot: true
        runAsUser: 2000
    createSecretJob:
      securityContext: {}
    patchWebhookJob:
      securityContext: {}
    certManager:
      enabled: ${var.cert_manager_enabled}
      rootCert:
        duration: ""  # default to be 5y
      admissionCert:
        duration: ""  # default to be 1y
      issuerRef:
        name: "${var.cert_manager_cluster_issuer_name}"
        kind: "ClusterIssuer"
  namespaces: {}
  denyNamespaces: []
  alertmanagerInstanceNamespaces: []
  alertmanagerConfigNamespaces: []
  prometheusInstanceNamespaces: []
  thanosRulerInstanceNamespaces: []
  # clusterDomain: "cluster.local"
  networkPolicy:
    enabled: false
  serviceAccount:
    create: true
    name: ""
  service:
    annotations: {}
    labels: {}
    clusterIP: ""
    additionalPorts: []
    type: ClusterIP
  labels: {}
  annotations: {}
  podLabels: {}
  podAnnotations: {}
  # priorityClassName: ""
  logFormat: json
  # logLevel: error
  kubeletService:
    enabled: true
    namespace: kube-system
    name: ""
  serviceMonitor:
    additionalLabels: {}
    interval: ""
    sampleLimit: 0
    targetLimit: 0
    labelLimit: 0
    labelNameLengthLimit: 0
    labelValueLengthLimit: 0
    scrapeTimeout: ""
    selfMonitor: true
    metricRelabelings: []
    relabelings: []
  resources: {}
  # limits:
  #   cpu: 200m
  #   memory: 200Mi
  # requests:
  #   cpu: 100m
  #   memory: 100Mi
  hostNetwork: false
  nodeSelector: {}
  tolerations: []
  affinity: {}
  dnsConfig: {}
  securityContext:
    fsGroup: 65534
    runAsGroup: 65534
    runAsNonRoot: true
    runAsUser: 65534
  containerSecurityContext:
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
  verticalPodAutoscaler:
    enabled: false
  prometheusConfigReloader:
    resources:
      requests:
        cpu: 200m
        memory: 50Mi
      limits:
        cpu: 200m
        memory: 50Mi
  prometheusInstanceSelector: ""
  alertmanagerInstanceSelector: ""
  thanosRulerInstanceSelector: ""
  secretFieldSelector: ""

prometheus:
  enabled: true
  annotations: {}
  networkPolicy:
    enabled: false
    # egress:
    # - {}
    # ingress:
    # - {}
    # podSelector:
    #   matchLabels:
    #     app: prometheus
  serviceAccount:
    create: true
    name: ""
    annotations: {}
  service:
    annotations: {}
    labels: {}
    clusterIP: ""
    port: 9090
    targetPort: 9090
    externalIPs: []
    type: ClusterIP
    additionalPorts: []
    publishNotReadyAddresses: false
    sessionAffinity: ""
  servicePerReplica:
    enabled: false
%{ if local.actual_replica_count > 1 ~}
  podDisruptionBudget:
    enabled: true
    minAvailable:
    maxUnavailable: 1
%{ endif ~}
  extraSecret:
    # name: ""
    annotations: {}
    data: {}
  ingress:
    enabled: false
  podSecurityPolicy:
    allowedCapabilities: []
    allowedHostPaths: []
    volumes: []
  serviceMonitor:
    interval: ""
    selfMonitor: true
    additionalLabels: {}
    sampleLimit: 0
    targetLimit: 0
    labelLimit: 0
    labelNameLengthLimit: 0
    labelValueLengthLimit: 0
    scheme: ""
    tlsConfig: {}
    bearerTokenFile:
    metricRelabelings: []
    relabelings: []
  prometheusSpec:
    disableCompaction: false
    apiserverConfig: {}
    additionalArgs: []
    scrapeInterval: ""
    scrapeTimeout: ""
    evaluationInterval: ""
    listenLocal: false
    enableAdminAPI: false
    version: ""
    web: {}
    exemplars: ""
    # maxSize: 100000
    enableFeatures: []
    tolerations: []
    topologySpreadConstraints: []
    alertingEndpoints: []
    externalLabels: {}
    enableRemoteWriteReceiver: false
    replicaExternalLabelName: ""
    replicaExternalLabelNameClear: false
    prometheusExternalLabelName: ""
    prometheusExternalLabelNameClear: false
    externalUrl: ""
    nodeSelector: {}
    secrets: []
    configMaps: []
    query: {}
    ruleNamespaceSelector: {}
    ruleSelectorNilUsesHelmValues: false
    ruleSelector: {}
    serviceMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelector: {}
    serviceMonitorNamespaceSelector: {}
    podMonitorSelectorNilUsesHelmValues: false
    podMonitorSelector: {}
    podMonitorNamespaceSelector: {}
    probeSelectorNilUsesHelmValues: false
    probeSelector: {}
    probeNamespaceSelector: {}
    retention: ${var.retention_days}d
    retentionSize: ""
    tsdb:
      outOfOrderTimeWindow: 0s
    walCompression: true
    paused: false
    replicas: ${local.actual_replica_count}
    shards: 1
    logLevel: info
    logFormat: json
    routePrefix: /
    podMetadata: {}
    podAntiAffinity: "soft"
    podAntiAffinityTopologyKey: kubernetes.io/hostname
    affinity: {}
    remoteRead: []
    additionalRemoteRead: []
    remoteWrite: []
    additionalRemoteWrite: []
    remoteWriteDashboards: false
    resources: {}
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: ${var.kubernetes_storage_class_name}
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: "${var.prometheus_storage_size}Gi"
        selector: {}
    volumes: []
    volumeMounts: []
    additionalScrapeConfigs: []
    additionalScrapeConfigsSecret: {}
    additionalPrometheusSecretsAnnotations: {}
    additionalAlertManagerConfigs: []
    additionalAlertManagerConfigsSecret: {}
    additionalAlertRelabelConfigs: []
    additionalAlertRelabelConfigsSecret: {}
    securityContext:
      runAsGroup: 2000
      runAsNonRoot: true
      runAsUser: 1000
      fsGroup: 2000
    priorityClassName: ""
    thanos: {}
    containers: []
    initContainers: []
    portName: "http-web"
    arbitraryFSAccessThroughSMs: false
    overrideHonorLabels: false
    overrideHonorTimestamps: false
    ignoreNamespaceSelectors: false
    enforcedNamespaceLabel: ""
    prometheusRulesExcludedFromEnforce: []
    excludedFromEnforcement: []
    queryLogFile: false
    enforcedSampleLimit: false
    enforcedTargetLimit: false
    enforcedLabelLimit: false
    enforcedLabelNameLengthLimit: false
    enforcedLabelValueLengthLimit: false
    allowOverlappingBlocks: false
    minReadySeconds: 0
    hostNetwork: false
    hostAliases: []
  additionalRulesForClusterRole: []
  additionalServiceMonitors: []
  additionalPodMonitors: []

thanosRuler:
  enabled: false

cleanPrometheusOperatorObjectNames: true
EOT
}

resource helm_release kube_prometheus_stack {
  chart = "kube-prometheus-stack"
  version = var.helm_chart_version
  name = var.helm_release_name
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  create_namespace = true
  namespace = var.kubernetes_namespace_owned ? kubernetes_namespace_v1.monitoring[0].metadata[0].name : var.kubernetes_namespace_name
  repository = "https://prometheus-community.github.io/helm-charts"
  values = [ local.prometheus_stack_values ]
}