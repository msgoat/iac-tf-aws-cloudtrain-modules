locals {
  prometheus_stack_values = <<EOT
## Create default rules for monitoring the cluster
##
defaultRules:
  create: true
  rules:
    alertmanager: true
    etcd: true
    configReloaders: true
    general: true
    k8s: true
    kubeApiserver: true
    kubeApiserverAvailability: true
    kubeApiserverSlos: true
    kubelet: true
    kubeProxy: true
    kubePrometheusGeneral: true
    kubePrometheusNodeRecording: true
    kubernetesApps: true
    kubernetesResources: true
    kubernetesStorage: true
    kubernetesSystem: true
    kubeScheduler: true
    kubeStateMetrics: true
    network: true
    node: true
    nodeExporterAlerting: true
    nodeExporterRecording: true
    prometheus: true
    prometheusOperator: true

  ## Reduce app namespace alert scope
  appNamespacesTarget: ".*"

  ## Labels for default rules
  labels: {}
  ## Annotations for default rules
  annotations: {}

  ## Additional labels for PrometheusRule alerts
  additionalRuleLabels: {}

  ## Prefix for runbook URLs. Use this to override the first part of the runbookURLs that is common to all rules.
  runbookUrl: "https://runbooks.prometheus-operator.dev/runbooks"

  ## Disabled PrometheusRule alerts
  disabled: {}
  # KubeAPIDown: true
  # NodeRAIDDegraded: true

##
global:
  rbac:
    create: true

## Configuration for alertmanager
## ref: https://prometheus.io/docs/alerting/alertmanager/
##
alertmanager:

  ## Deploy alertmanager
  ##
  enabled: false

  ## Annotations for Alertmanager
  ##
  annotations: {}

  ## Api that prometheus will use to communicate with alertmanager. Possible values are v1, v2
  ##
  apiVersion: v2

  ## Service account for Alertmanager to use.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
  ##
  serviceAccount:
    create: true

  ## Configure pod disruption budgets for Alertmanager
  ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget
  ## This configuration is immutable once created and will require the PDB to be deleted to be changed
  ## https://github.com/kubernetes/kubernetes/issues/45398
  ##
  podDisruptionBudget:
    enabled: true
    maxUnavailable: 1

    ## Define Log Format
    # Use logfmt (default) or json logging
    logFormat: json

    ## Log level for Alertmanager to be configured with.
    ##
    logLevel: info

    ## Size is the expected size of the alertmanager cluster. The controller will eventually make the size of the
    ## running cluster equal to the expected size.
    replicas: 2

    ## Time duration Alertmanager shall retain data for. Default is '120h', and must match the regular expression
    ## [0-9]+(ms|s|m|h) (milliseconds seconds minutes hours).
    ##
    retention: 120h

    ## Storage is the definition of how storage will be used by the Alertmanager instances.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/storage.md
    ##
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: gp2
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
        selector: {}


    ## The external URL the Alertmanager instances will be available under. This is necessary to generate correct URLs. This is necessary if Alertmanager is not served from root of a DNS name. string  false
    ##
    externalUrl:

    ## The route prefix Alertmanager registers HTTP handlers for. This is useful, if using ExternalURL and a proxy is rewriting HTTP routes of a request, and the actual ExternalURL is still true,
    ## but the server serves requests under a different route prefix. For example for use with kubectl proxy.
    ##
    routePrefix: /

    ## If set to true all actions on the underlying managed objects are not going to be performed, except for delete actions.
    ##
    paused: false

    ## Define which Nodes the Pods are scheduled on.
    ## ref: https://kubernetes.io/docs/user-guide/node-selection/
    ##
    nodeSelector: {}

    ## Define resources requests and limits for single Pods.
    ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
    ##
    resources:
      requests:
        memory: 400Mi

    ## Pod anti-affinity can prevent the scheduler from placing Prometheus replicas on the same node.
    ## The default value "soft" means that the scheduler should *prefer* to not schedule two replica pods onto the same node but no guarantee is provided.
    ## The value "hard" means that the scheduler is *required* to not schedule two replica pods onto the same node.
    ## The value "" will disable pod anti-affinity so that no anti-affinity rules will be configured.
    ##
    podAntiAffinity: "hard"

    ## SecurityContext holds pod-level security attributes and common container settings.
    ## This defaults to non root user with uid 1000 and gid 2000. *v1.PodSecurityContext  false
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
    ##
    securityContext:
      runAsGroup: 2000
      runAsNonRoot: true
      runAsUser: 1000
      fsGroup: 2000

## Using default values from https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml
##
grafana:
  enabled: true

  ## ForceDeployDatasources Create datasource configmap even if grafana deployment has been disabled
  ##
  forceDeployDatasources: false

  ## ForceDeployDashboard Create dashboard configmap even if grafana deployment has been disabled
  ##
  forceDeployDashboards: false

  ## Deploy default dashboards
  ##
  defaultDashboardsEnabled: true

  ## Timezone for the default dashboards
  ## Other options are: browser or a specific timezone, i.e. Europe/Luxembourg
  ##
  defaultDashboardsTimezone: utc

  adminPassword: prom-operator

  rbac:
    ## If true, Grafana PSPs will be created
    ##
    pspEnabled: false

  ingress:
    ## If true, Grafana Ingress will be created
    ##
    enabled: true

    ## IngressClassName for Grafana Ingress.
    ## Should be provided if Ingress is enable.
    ##
    ingressClassName: traefik

    ## Annotations for Grafana Ingress
    ##
    annotations: {}
      # kubernetes.io/ingress.class: nginx
      # kubernetes.io/tls-acme: "true"

    ## Hostnames.
    ## Must be provided if Ingress is enable.
    ##
    # hosts:
    #   - grafana.domain.com
    hosts:
      - ${var.grafana_host_name}

    ## Path for grafana ingress
    path: ${var.grafana_path}

  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard
      labelValue: "1"

      ## Annotations for Grafana dashboard configmaps
      ##
      annotations: {}
      multicluster:
        global:
          enabled: false
        etcd:
          enabled: false
      provider:
        allowUiUpdates: false
    datasources:
      enabled: true
      defaultDatasourceEnabled: true

      uid: prometheus

      ## URL of prometheus datasource
      ##
      # url: http://prometheus-stack-prometheus:9090/

      # If not defined, will use prometheus.prometheusSpec.scrapeInterval or its default
      # defaultDatasourceScrapeInterval: 15s

      ## Annotations for Grafana datasource configmaps
      ##
      annotations: {}

      ## Create datasource for each Pod of Prometheus StatefulSet;
      ## this uses headless service `prometheus-operated` which is
      ## created by Prometheus Operator
      ## ref: https://git.io/fjaBS
      createPrometheusReplicasDatasources: false
      label: grafana_datasource
      labelValue: "1"

  extraConfigmapMounts: []
  # - name: certs-configmap
  #   mountPath: /etc/grafana/ssl/
  #   configMap: certs-configmap
  #   readOnly: true

  deleteDatasources: []
  # - name: example-datasource
  #   orgId: 1

  ## Configure additional grafana datasources (passed through tpl)
  ## ref: http://docs.grafana.org/administration/provisioning/#datasources
  additionalDataSources: []
  # - name: prometheus-sample
  #   access: proxy
  #   basicAuth: true
  #   basicAuthPassword: pass
  #   basicAuthUser: daco
  #   editable: false
  #   jsonData:
  #       tlsSkipVerify: true
  #   orgId: 1
  #   type: prometheus
  #   url: https://{{ printf "%s-prometheus.svc" .Release.Name }}:9090
  #   version: 1

  ## Passed to grafana subchart and used by servicemonitor below
  ##
  service:
    portName: http-web

  serviceMonitor:
    # If true, a ServiceMonitor CRD is created for a prometheus operator
    # https://github.com/coreos/prometheus-operator
    #
    enabled: true

    # Path to use for scraping metrics. Might be different if server.root_url is set
    # in grafana.ini
    path: "/metrics"

## Component scraping the kube api server
##
kubeApiServer:
  enabled: true
  tlsConfig:
    serverName: kubernetes
    insecureSkipVerify: false

## Component scraping the kubelet and kubelet-hosted cAdvisor
##
kubelet:
  enabled: true
  namespace: kube-system

## Component scraping the kube controller manager
##
kubeControllerManager:
  enabled: true

## Component scraping coreDns. Use either this or kubeDns
##
coreDns:
  enabled: true
  service:
    port: 9153
    targetPort: 9153
    # selector:
    #   k8s-app: kube-dns

## Component scraping kubeDns. Use either this or coreDns
##
kubeDns:
  enabled: false
  service:
    dnsmasq:
      port: 10054
      targetPort: 10054
    skydns:
      port: 10055
      targetPort: 10055
    # selector:
    #   k8s-app: kube-dns

## Component scraping etcd
##
kubeEtcd:
  enabled: true

  ## Etcd service. If using kubeEtcd.endpoints only the port and targetPort are used
  ##
  service:
    enabled: true
    port: 2379
    targetPort: 2379
    # selector:
    #   component: etcd

  ## Configure secure access to the etcd cluster by loading a secret into prometheus and
  ## specifying security configuration below. For example, with a secret named etcd-client-cert
  ##
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

## Component scraping kube scheduler
##
kubeScheduler:
  enabled: true

  ## If using kubeScheduler.endpoints only the port and targetPort are used
  ##
  service:
    enabled: true
    ## If null or unset, the value is determined dynamically based on target Kubernetes version due to change
    ## of default port in Kubernetes 1.23.
    ##
    port: null
    targetPort: null
    # selector:
    #   component: kube-scheduler

  serviceMonitor:
    enabled: true

## Component scraping kube proxy
##
kubeProxy:
  enabled: true

  service:
    enabled: true
    port: 10249
    targetPort: 10249
    # selector:
    #   k8s-app: kube-proxy

  serviceMonitor:
    enabled: true

## Component scraping kube state metrics
##
kubeStateMetrics:
  enabled: true

## Configuration for kube-state-metrics subchart
##
kube-state-metrics:
  namespaceOverride: ""
  rbac:
    create: true
  releaseLabel: true
  prometheus:
    monitor:
      enabled: true

  selfMonitor:
    enabled: false

## Deploy node exporter as a daemonset to all nodes
##
nodeExporter:
  enabled: true

## Configuration for prometheus-node-exporter subchart
##
prometheus-node-exporter:
  namespaceOverride: ""
  podLabels:
    ## Add the 'node-exporter' label to be used by serviceMonitor to match standard common usage in rules and grafana dashboards
    ##
    jobLabel: node-exporter
  extraArgs:
    - --collector.filesystem.mount-points-exclude=^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/.+)($|/)
    - --collector.filesystem.fs-types-exclude=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$
  service:
    portName: http-metrics
  prometheus:
    monitor:
      enabled: true

      jobLabel: jobLabel

## Manages Prometheus and Alertmanager components
##
prometheusOperator:
  enabled: true

  ## Prometheus-Operator v0.39.0 and later support TLS natively.
  ##
  tls:
    enabled: true
    # Value must match version names from https://golang.org/pkg/crypto/tls/#pkg-constants
    tlsMinVersion: VersionTLS13
    # The default webhook port is 10250 in order to work out-of-the-box in GKE private clusters and avoid adding firewall rules.
    internalPort: 10250

  ## Admission webhook support for PrometheusRules resources added in Prometheus Operator 0.30 can be enabled to prevent incorrectly formatted
  ## rules from making their way into prometheus and potentially preventing the container from starting
  admissionWebhooks:
    failurePolicy: Fail
    enabled: true
    ## A PEM encoded CA bundle which will be used to validate the webhook's server certificate.
    ## If unspecified, system trust roots on the apiserver are used.
    caBundle: ""
    ## If enabled, generate a self-signed certificate, then patch the webhook configurations with the generated data.
    ## On chart upgrades (or if the secret exists) the cert will not be re-generated. You can use this to provide your own
    ## certs ahead of time if you wish.
    ##
    patch:
      enabled: true
      resources: {}
      ## SecurityContext holds pod-level security attributes and common container settings.
      ## This defaults to non root user with uid 2000 and gid 2000. *v1.PodSecurityContext  false
      ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
      ##
      securityContext:
        runAsGroup: 2000
        runAsNonRoot: true
        runAsUser: 2000

    # Use certmanager to generate webhook certs
    certManager:
      enabled: false
      # self-signed root certificate
      rootCert:
        duration: ""  # default to be 5y
      admissionCert:
        duration: ""  # default to be 1y
      # issuerRef:
      #   name: "issuer"
      #   kind: "ClusterIssuer"

  ## Namespaces to scope the interaction of the Prometheus Operator and the apiserver (allow list).
  ## This is mutually exclusive with denyNamespaces. Setting this to an empty object will disable the configuration
  ##
  namespaces: {}
    # releaseNamespace: true
    # additional:
    # - kube-system

  ## Namespaces not to scope the interaction of the Prometheus Operator (deny list).
  ##
  denyNamespaces: []

  ## Filter namespaces to look for prometheus-operator custom resources
  ##
  alertmanagerInstanceNamespaces: []
  prometheusInstanceNamespaces: []
  thanosRulerInstanceNamespaces: []

  ## The clusterDomain value will be added to the cluster.peer option of the alertmanager.
  ## Without this specified option cluster.peer will have value alertmanager-monitoring-alertmanager-0.alertmanager-operated:9094 (default value)
  ## With this specified option cluster.peer will have value alertmanager-monitoring-alertmanager-0.alertmanager-operated.namespace.svc.cluster-domain:9094
  ##
  # clusterDomain: "cluster.local"

  ## Service account for Alertmanager to use.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
  ##
  serviceAccount:
    create: true
    name: ""

  ## Configuration for Prometheus operator service
  ##
  service:
    annotations: {}
    labels: {}
    clusterIP: ""

  ## Define Log Format
  # Use logfmt (default) or json logging
  logFormat: json

  ## Decrease log verbosity to errors only
  # logLevel: error

  ## If true, the operator will create and maintain a service for scraping kubelets
  ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/helm/prometheus-operator/README.md
  ##
  kubeletService:
    enabled: true
    namespace: kube-system
    ## Use '{{ template "kube-prometheus-stack.fullname" . }}-kubelet' by default
    name: ""

  ## Create a servicemonitor for the operator
  ##
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""
    ## Scrape timeout. If not set, the Prometheus default scrape timeout is used.
    scrapeTimeout: ""
    selfMonitor: true

  ## Resource limits & requests
  ##
  resources:
    limits:
      cpu: 200m
      memory: 200Mi
    requests:
      cpu: 100m
      memory: 100Mi
  securityContext:
    fsGroup: 65534
    runAsGroup: 65534
    runAsNonRoot: true
    runAsUser: 65534

  ## Container-specific security context configuration
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  ##
  containerSecurityContext:
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true

  ## Prometheus-config-reloader
  ##
  prometheusConfigReloader:
    # resource config for prometheusConfigReloader
    resources:
      requests:
        cpu: 200m
        memory: 50Mi
      limits:
        cpu: 200m
        memory: 50Mi

## Deploy a Prometheus instance
##
prometheus:

  enabled: true

  ## Service account for Prometheuses to use.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
  ##
  serviceAccount:
    create: true

  ## Configure pod disruption budgets for Prometheus
  ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget
  ## This configuration is immutable once created and will require the PDB to be deleted to be changed
  ## https://github.com/kubernetes/kubernetes/issues/45398
  ##
  podDisruptionBudget:
    enabled: false
    minAvailable: 1
    maxUnavailable: ""

  ingress:
    enabled: ${var.prometheus_ui_enabled}

    # For Kubernetes >= 1.18 you should specify the ingress-controller via the field ingressClassName
    # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
    ingressClassName: traefik

    annotations: {}
    labels: {}

    ## Hostnames.
    ## Must be provided if Ingress is enabled.
    ##
    # hosts:
    #   - prometheus.domain.com
    hosts:
      - ${var.prometheus_host_name}

    ## Paths to use for ingress rules - one path should match the prometheusSpec.routePrefix
    ##
    paths:
      - ${var.prometheus_path}

    ## For Kubernetes >= 1.18 you should specify the pathType (determines how Ingress paths should be matched)
    ## See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#better-path-matching-with-path-types
    pathType: Prefix

  ## Configure additional options for default pod security policy for Prometheus
  ## ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/
  podSecurityPolicy:
    allowedCapabilities: []
    allowedHostPaths: []
    volumes: []

  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""
    selfMonitor: true

  ## Settings affecting prometheusSpec
  ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#prometheusspec
  ##
  prometheusSpec:
    ## If true, pass --storage.tsdb.max-block-duration=2h to prometheus. This is already done if using Thanos
    ##
    disableCompaction: false
    ## APIServerConfig
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#apiserverconfig
    ##
    apiserverConfig: {}

    ## Interval between consecutive scrapes.
    ## Defaults to 30s.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/release-0.44/pkg/prometheus/promcfg.go#L180-L183
    ##
    scrapeInterval: ""

    ## Number of seconds to wait for target to respond before erroring
    ##
    scrapeTimeout: ""

    ## Interval between consecutive evaluations.
    ##
    evaluationInterval: ""

    ## ListenLocal makes the Prometheus server listen on loopback, so that it does not bind against the Pod IP.
    ##
    listenLocal: false

    ## EnableAdminAPI enables Prometheus the administrative HTTP API which includes functionality such as deleting time series.
    ## This is disabled by default.
    ## ref: https://prometheus.io/docs/prometheus/latest/querying/api/#tsdb-admin-apis
    ##
    enableAdminAPI: false

    ## WebTLSConfig defines the TLS parameters for HTTPS
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#webtlsconfig
    web: {}

    # EnableFeatures API enables access to Prometheus disabled features.
    # ref: https://prometheus.io/docs/prometheus/latest/disabled_features/
    enableFeatures: []
    # - exemplar-storage

    ## External URL at which Prometheus will be reachable.
    ##
    externalUrl: ""

    ## If true, a nil or {} value for prometheus.prometheusSpec.ruleSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the PrometheusRule resources created
    ##
    ruleSelectorNilUsesHelmValues: false

    ## If true, a nil or {} value for prometheus.prometheusSpec.serviceMonitorSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the servicemonitors created
    ##
    serviceMonitorSelectorNilUsesHelmValues: false

    ## ServiceMonitors to be selected for target discovery.
    ## If {}, select all ServiceMonitors
    ##
    serviceMonitorSelector: {}
    ## Example which selects ServiceMonitors with label "prometheus" set to "somelabel"
    # serviceMonitorSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## Namespaces to be selected for ServiceMonitor discovery.
    ##
    serviceMonitorNamespaceSelector: {}
    ## Example which selects ServiceMonitors in namespaces with label "prometheus" set to "somelabel"
    # serviceMonitorNamespaceSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## If true, a nil or {} value for prometheus.prometheusSpec.podMonitorSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the podmonitors created
    ##
    podMonitorSelectorNilUsesHelmValues: true

    ## PodMonitors to be selected for target discovery.
    ## If {}, select all PodMonitors
    ##
    podMonitorSelector: {}
    ## Example which selects PodMonitors with label "prometheus" set to "somelabel"
    # podMonitorSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## Namespaces to be selected for PodMonitor discovery.
    ## See https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#namespaceselector for usage
    ##
    podMonitorNamespaceSelector: {}

    ## If true, a nil or {} value for prometheus.prometheusSpec.probeSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the probes created
    ##
    probeSelectorNilUsesHelmValues: true

    ## Probes to be selected for target discovery.
    ## If {}, select all Probes
    ##
    probeSelector: {}
    ## Example which selects Probes with label "prometheus" set to "somelabel"
    # probeSelector:
    #   matchLabels:
    #     prometheus: somelabel

    ## Namespaces to be selected for Probe discovery.
    ## See https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#namespaceselector for usage
    ##
    probeNamespaceSelector: {}

    ## How long to retain metrics
    ##
    retention: 7d

    ## Maximum size of metrics
    ##
    retentionSize: ""

    ## Enable compression of the write-ahead log using Snappy.
    ##
    walCompression: false

    ## If true, the Operator won't process any Prometheus configuration changes
    ##
    paused: false

    ## Number of replicas of each shard to deploy for a Prometheus deployment.
    ## Number of replicas multiplied by shards is the total number of Pods created.
    ##
    replicas: 2

    ## EXPERIMENTAL: Number of shards to distribute targets onto.
    ## Number of replicas multiplied by shards is the total number of Pods created.
    ## Note that scaling down shards will not reshard data onto remaining instances, it must be manually moved.
    ## Increasing shards will not reshard data either but it will continue to be available from the same instances.
    ## To query globally use Thanos sidecar and Thanos querier or remote write data to a central location.
    ## Sharding is done on the content of the `__address__` target meta-label.
    ##
    shards: 1

    ## Log level for Prometheus be configured in
    ##
    logLevel: info

    ## Log format for Prometheus be configured in
    ##
    logFormat: json

    ## Prefix used to register routes, overriding externalUrl route.
    ## Useful for proxies that rewrite URLs.
    ##
    routePrefix: /

    ## Resource limits & requests
    ##
    resources:
      requests:
        memory: 400Mi

    ## Prometheus StorageSpec for persistent data
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/storage.md
    ##
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: gp2
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi

    ## SecurityContext holds pod-level security attributes and common container settings.
    ## This defaults to non root user with uid 1000 and gid 2000.
    ## https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md
    ##
    securityContext:
      runAsGroup: 2000
      runAsNonRoot: true
      runAsUser: 1000
      fsGroup: 2000

    ## ArbitraryFSAccessThroughSMs configures whether configuration based on a service monitor can access arbitrary files
    ## on the file system of the Prometheus container e.g. bearer token files.
    arbitraryFSAccessThroughSMs: false

    ## OverrideHonorLabels if set to true overrides all user configured honor_labels. If HonorLabels is set in ServiceMonitor
    ## or PodMonitor to true, this overrides honor_labels to false.
    overrideHonorLabels: false

    ## OverrideHonorTimestamps allows to globally enforce honoring timestamps in all scrape configs.
    overrideHonorTimestamps: false

    ## IgnoreNamespaceSelectors if set to true will ignore NamespaceSelector settings from the podmonitor and servicemonitor
    ## configs, and they will only discover endpoints within their current namespace. Defaults to false.
    ignoreNamespaceSelectors: false

    ## EnforcedNamespaceLabel enforces adding a namespace label of origin for each alert and metric that is user created.
    ## The label value will always be the namespace of the object that is being created.
    ## Disabled by default
    enforcedNamespaceLabel: ""

    ## PrometheusRulesExcludedFromEnforce - list of prometheus rules to be excluded from enforcing of adding namespace labels.
    ## Works only if enforcedNamespaceLabel set to true. Make sure both ruleNamespace and ruleName are set for each pair
    prometheusRulesExcludedFromEnforce: []

    ## QueryLogFile specifies the file to which PromQL queries are logged. Note that this location must be writable,
    ## and can be persisted using an attached volume. Alternatively, the location can be set to a stdout location such
    ## as /dev/stdout to log querie information to the default Prometheus log stream. This is only available in versions
    ## of Prometheus >= 2.16.0. For more details, see the Prometheus docs (https://prometheus.io/docs/guides/query-log/)
    queryLogFile: false

    ## EnforcedSampleLimit defines global limit on number of scraped samples that will be accepted. This overrides any SampleLimit
    ## set per ServiceMonitor or/and PodMonitor. It is meant to be used by admins to enforce the SampleLimit to keep overall
    ## number of samples/series under the desired limit. Note that if SampleLimit is lower that value will be taken instead.
    enforcedSampleLimit: false

    ## EnforcedTargetLimit defines a global limit on the number of scraped targets. This overrides any TargetLimit set
    ## per ServiceMonitor or/and PodMonitor. It is meant to be used by admins to enforce the TargetLimit to keep the overall
    ## number of targets under the desired limit. Note that if TargetLimit is lower, that value will be taken instead, except
    ## if either value is zero, in which case the non-zero value will be used. If both values are zero, no limit is enforced.
    enforcedTargetLimit: false

    ## Per-scrape limit on number of labels that will be accepted for a sample. If more than this number of labels are present
    ## post metric-relabeling, the entire scrape will be treated as failed. 0 means no limit. Only valid in Prometheus versions
    ## 2.27.0 and newer.
    enforcedLabelLimit: false

    ## Per-scrape limit on length of labels name that will be accepted for a sample. If a label name is longer than this number
    ## post metric-relabeling, the entire scrape will be treated as failed. 0 means no limit. Only valid in Prometheus versions
    ## 2.27.0 and newer.
    enforcedLabelNameLengthLimit: false

    ## Per-scrape limit on length of labels value that will be accepted for a sample. If a label value is longer than this
    ## number post metric-relabeling, the entire scrape will be treated as failed. 0 means no limit. Only valid in Prometheus
    ## versions 2.27.0 and newer.
    enforcedLabelValueLengthLimit: false

    ## AllowOverlappingBlocks enables vertical compaction and vertical query merge in Prometheus. This is still experimental
    ## in Prometheus so it may change in any upcoming release.
    allowOverlappingBlocks: false
EOT
}

resource helm_release kube_prometheus_stack {
  chart = "kube-prometheus-stack"
  version = "34.9.0"
  name = var.helm_release_name
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  create_namespace = true
  namespace = var.kubernetes_namespace_name
  repository = "https://prometheus-community.github.io/helm-charts"
  values = [ local.prometheus_stack_values ]
}