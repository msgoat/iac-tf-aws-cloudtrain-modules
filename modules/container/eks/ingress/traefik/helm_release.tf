locals {

  traefik_values = <<EOT
# Default values for Traefik

hub:
  enabled: false

deployment:
  enabled: true
  kind: Deployment
  replicas: ${var.replica_count}
  # revisionHistoryLimit: 1
  terminationGracePeriodSeconds: 60
  minReadySeconds: 0
  annotations: {}
  labels: {}
  podAnnotations: {}
  podLabels: {}
  additionalContainers: []
  additionalVolumes: []
  initContainers: []
  shareProcessNamespace: false
  lifecycle: {}
    # preStop:
    #   exec:
    #     command: ["/bin/sh", "-c", "sleep 40"]
    # postStart:
    #   httpGet:
    #     path: /ping
    #     port: 9000
    #     host: localhost
    #     scheme: HTTP

%{ if var.replica_count > 1 ~}
# Pod disruption budget
podDisruptionBudget:
  enabled: true
  maxUnavailable: 1
%{ endif ~}

ingressClass:
  enabled: true
  isDefaultClass: false

experimental:
  v3:
    enabled: false
  plugins:
    enabled: false
  kubernetesGateway:
    enabled: false
    gateway:
      enabled: true
    # certificate:
    #   group: "core"
    #   kind: "Secret"
    #   name: "mysecret"
    # By default, Gateway would be created to the Namespace you are deploying Traefik to.
    # You may create that Gateway in another namespace, setting its name below:
    # namespace: default
    # Additional gateway annotations (e.g. for cert-manager.io/issuer)
    # annotations:
    #   cert-manager.io/issuer: letsencrypt

ingressRoute:
  dashboard:
    enabled: true
    annotations: {}
    labels: {}
    matchRule: PathPrefix(`/dashboard`) || PathPrefix(`/api`)
    entryPoints: ["traefik"]
    middlewares: []
    tls: {}

updateStrategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1

readinessProbe:
  failureThreshold: 1
  initialDelaySeconds: 2
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 2

livenessProbe:
  failureThreshold: 3
  initialDelaySeconds: 2
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 2

providers:
  kubernetesCRD:
    enabled: true
    allowCrossNamespace: false
    allowExternalNameServices: false
    allowEmptyServices: false
    namespaces: []

  kubernetesIngress:
    enabled: true
    allowExternalNameServices: false
    allowEmptyServices: false
    namespaces: []
    publishedService:
      enabled: false

# additionalArguments:
# - "--providers.file.filename=/config/dynamic.toml"
# - "--ping"
# - "--ping.entrypoint=web"

volumes: []
# - name: public-cert
#   mountPath: "/certs"
#   type: secret
# - name: '{{ printf "%s-configs" .Release.Name }}'
#   mountPath: "/config"
#   type: configMap

additionalVolumeMounts: []

logs:
  general:
    format: json
    level: ERROR
  access:
    enabled: false
    format: json
    filters: {}
      # statuscodes: "200,300-302"
      # retryattempts: true
      # minduration: 10ms
    fields:
      general:
        defaultmode: keep
        names: {}
          ## Examples:
          # ClientUsername: drop
      headers:
        defaultmode: drop
        names: {}
          ## Examples:
          # User-Agent: redact
          # Authorization: drop
          # Content-Type: keep

metrics:
  prometheus:
    entryPoint: metrics
  #  service:
  #    enabled: false
  #    labels: {}
  #    annotations: {}
  ## When set to true, it won't check if Prometheus Operator CRDs are deployed
  #  disableAPICheck: false
  #  serviceMonitor:
  #    metricRelabelings: []
  #      - sourceLabels: [__name__]
  #        separator: ;
  #        regex: ^fluentd_output_status_buffer_(oldest|newest)_.+
  #        replacement: $1
  #        action: drop
  #    relabelings: []
  #      - sourceLabels: [__meta_kubernetes_pod_node_name]
  #        separator: ;
  #        regex: ^(.*)$
  #        targetLabel: nodename
  #        replacement: $1
  #        action: replace
  #    jobLabel: traefik
  #    interval: 30s
  #    honorLabels: true
  #    # (Optional)
  #    # scrapeTimeout: 5s
  #    # honorTimestamps: true
  #    # enableHttp2: true
  #    # followRedirects: true
  #    # additionalLabels:
  #    #   foo: bar
  #    # namespace: "another-namespace"
  #    # namespaceSelector: {}
  #  prometheusRule:
  #    additionalLabels: {}
  #    namespace: "another-namespace"
  #    rules:
  #      - alert: TraefikDown
  #        expr: up{job="traefik"} == 0
  #        for: 5m
  #        labels:
  #          context: traefik
  #          severity: warning
  #        annotations:
  #          summary: "Traefik Down"
  #          description: "{{ $labels.pod }} on {{ $labels.nodename }} is down"

%{ if var.jaeger_enabled ~}
tracing:
  jaeger:
    samplingType: const
    samplingParam: 1.0
    localAgentHostPort: ${var.jaeger_agent_host}:${var.jaeger_agent_port}
  #   gen128Bit: false
    propagation: jaeger
    traceContextHeaderName: uber-trace-id
    disableAttemptReconnecting: true
%{ else ~}
tracing: {}
%{ endif ~}

globalArguments: []

additionalArguments: []

env: []

envFrom: []

# Configure ports
ports:
  # The name of this one can't be changed as it is used for the readiness and
  # liveness probes, but you can adjust its config to your liking
  traefik:
    port: 9000
    # hostPort: 9000
    # hostIP: 192.168.100.10
    # healthchecksPort: 9000
    # healthchecksScheme: HTTPS
    expose: false
    exposedPort: 9000
    protocol: TCP
  web:
    # asDefault: true
    port: 8000
    # hostPort: 8000
    expose: true
    exposedPort: 80
    protocol: TCP
    nodePort: 32080
    # Port Redirections
    # redirectTo: websecure
    # forwardedHeaders:
    #   trustedIPs: []
    #   insecure: false
    # proxyProtocol:
    #   trustedIPs: []
    #   insecure: false
  websecure:
    # asDefault: true
    port: 8443
    # hostPort: 8443
    expose: true
    exposedPort: 443
    protocol: TCP
    nodePort: 32443
    http3:
      enabled: false
    # advertisedPort: 4443
    #forwardedHeaders:
    #  trustedIPs: []
    #  insecure: false
    #proxyProtocol:
    #  trustedIPs: []
    #  insecure: false
    tls:
      enabled: true
      # this is the name of a TLSOption definition
      options: ""
      certResolver: ""
      domains: []
      # - main: example.com
      #   sans:
      #     - foo.example.com
      #     - bar.example.com
    #
    middlewares: []
  metrics:
    port: 9100
    # hostPort: 9100
    expose: false
    # The exposed port for this service
    exposedPort: 9100
    # The port protocol (TCP/UDP)
    protocol: TCP

# tlsOptions:
#   default:
#     sniStrict: true
#     preferServerCipherSuites: true
#   foobar:
#     curvePreferences:
#       - CurveP521
#       - CurveP384
tlsOptions: {}

# tlsStore:
#   default:
#     defaultCertificate:
#       secretName: tls-cert
tlsStore: {}

service:
  enabled: true
  single: true
%{ if var.load_balancer_strategy == "SERVICE_VIA_NODE_PORT" ~}
  type: NodePort
%{ else ~}
  type: ClusterIP
%{ endif ~}
  annotations: {}
  annotationsTCP: {}
  annotationsUDP: {}
  labels: {}
  spec: {}
  loadBalancerSourceRanges: []
  externalIPs: []
  # ipFamilyPolicy: SingleStack
  # ipFamilies:
  #   - IPv4
  #   - IPv6
  # internal:
  #   type: ClusterIP
  #   # labels: {}
  #   # annotations: {}
  #   # spec: {}
  #   # loadBalancerSourceRanges: []
  #   # externalIPs: []
  #   # ipFamilies: [ "IPv4","IPv6" ]

autoscaling:
  enabled: false
#   minReplicas: 1
#   maxReplicas: 10
#   metrics:
#   - type: Resource
#     resource:
#       name: cpu
#       target:
#         type: Utilization
#         averageUtilization: 60
#   - type: Resource
#     resource:
#       name: memory
#       target:
#         type: Utilization
#         averageUtilization: 60
#   behavior:
#     scaleDown:
#       stabilizationWindowSeconds: 300
#       policies:
#       - type: Pods
#         value: 1
#         periodSeconds: 60

persistence:
  enabled: false
  name: data
#  existingClaim: ""
  accessMode: ReadWriteOnce
  size: 128Mi
  # storageClass: ""
  # volumeName: ""
  path: /data
  annotations: {}
  # subPath: "" # only mount a subpath of the Volume into the pod

certResolvers: {}

hostNetwork: false

rbac:
  enabled: true
  namespaced: false
  # aggregateTo: [ "admin" ]

podSecurityPolicy:
  enabled: false

serviceAccount:
  name: ""

serviceAccountAnnotations: {}

resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "300m"
    memory: "150Mi"

affinity: {}
nodeSelector: {}
tolerations: []
topologySpreadConstraints: []

priorityClassName: ""

securityContext:
  capabilities:
    drop: [ALL]
  readOnlyRootFilesystem: true

podSecurityContext:
#  fsGroup: 65532
  fsGroupChangePolicy: "OnRootMismatch"
  runAsGroup: 65532
  runAsNonRoot: true
  runAsUser: 65532

extraObjects: []

# namespaceOverride: traefik

# instanceLabelOverride: traefik
EOT
}

resource helm_release traefik {
  chart = "traefik"
  version = var.helm_chart_version
  name = var.helm_release_name
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  create_namespace = true
  namespace = kubernetes_namespace_v1.traefik.metadata[0].name
  repository = "https://traefik.github.io/charts"
  values = [ local.traefik_values ]
}