locals {
  jaeger_agent_cpu_request = "125m"
  jaeger_agent_cpu_limit = "250m"
  jaeger_agent_memory_request = "128Mi"
  jaeger_agent_memory_limit = "256Mi"
  helm_values = <<EOT
# Default values for jaeger.

provisionDataStore:
  cassandra: false
  elasticsearch: ${var.elasticsearch_strategy == "ES_INTERNAL" ? true : false}
  kafka: false

nameOverride: ""
fullnameOverride: ""

storage:
  # allowed values (cassandra, elasticsearch)
  type: elasticsearch
  elasticsearch:
%{ if var.elasticsearch_strategy == "ES_ECK_OPERATOR" ~}
    scheme: https
    host: ${local.elasticsearch_service_name}
    port: ${local.elasticsearch_service_port}
    user: elastic
    usePassword: true
    password: changeme
    existingSecret: ${local.elasticsearch_credentials_k8s_secret_name}
    existingSecretKey: elastic
    nodesWanOnly: false
    extraEnv: []
    cmdlineParams: {}
%{ endif ~}
%{ if var.elasticsearch_strategy == "ES_INTERNAL" ~}
    scheme: http
    host: elasticsearch-master.${var.kubernetes_namespace_name}
    port: 9200
    user: elastic
    usePassword: false
    password: changeme
    nodesWanOnly: false
    extraEnv: []
    cmdlineParams: {}
%{ endif ~}
  grpcPlugin:
    extraEnv: []

agent:
  podSecurityContext: {}
  securityContext: {}
  enabled: true
  annotations: {}
  imagePullSecrets: []
  pullPolicy: IfNotPresent
  cmdlineParams: {}
  extraEnv: []
  daemonset:
    useHostPort: false
    updateStrategy: {}
  service:
    type: ClusterIP
    zipkinThriftPort: 5775
    compactPort: 6831
    binaryPort: 6832
    samplingPort: 5778
  resources:
    limits:
      cpu: ${local.jaeger_agent_cpu_limit}
      memory: ${local.jaeger_agent_memory_limit}
    requests:
      cpu: ${local.jaeger_agent_cpu_request}
      memory: ${local.jaeger_agent_memory_request}
  serviceAccount:
    create: true
    automountServiceAccountToken: false
    name:
    annotations: {}
  nodeSelector: {}
%{ if var.node_group_workload_class != "" ~}
# It's OK to be deployed to the tools pool, too
  tolerations:
    - key: "group.msg.cloud.kubernetes/workload"
      operator: "Equal"
      value: ${var.node_group_workload_class}
      effect: "NoSchedule"
%{ endif ~}
  podAnnotations: {}
  podLabels: {}
  extraSecretMounts: []
  extraConfigmapMounts: []
  useHostNetwork: false
  dnsPolicy: ClusterFirst
  priorityClassName: ""
  initContainers: []
  serviceMonitor:
    enabled: true

collector:
  podSecurityContext: {}
  securityContext: {}
  enabled: true
  annotations: {}
  imagePullSecrets: []
  pullPolicy: IfNotPresent
  dnsPolicy: ClusterFirst
  extraEnv: []
%{ if var.elasticsearch_strategy == "ES_ECK_OPERATOR" ~}
  cmdlineParams:
    es.tls.enabled: "true"
    es.tls.ca: "/tls/ca.crt"
    # need to fallback ES client to ES 7 level since Jaeger cannot work with ES 8 out of the box
    es.version: 7
    es.create-index-templates: "false"
%{ else ~}
  cmdlineParams: {}
%{ endif ~}
  basePath: /
  replicaCount: 1
  autoscaling:
    enabled: false
    minReplicas: 2
    maxReplicas: 10
    # targetCPUUtilizationPercentage: 80
    # targetMemoryUtilizationPercentage: 80
  service:
    annotations: {}
    # The IP to be used by the load balancer (if supported)
    loadBalancerIP: ''
    # List of IP ranges that are allowed to access the load balancer (if supported)
    loadBalancerSourceRanges: []
    type: ClusterIP
    # Cluster IP address to assign to service. Set to None to make service headless
    clusterIP: ""
    grpc:
      port: 14250
      # nodePort:
    # httpPort: can accept spans directly from clients in jaeger.thrift format
    http:
      port: 14268
      # nodePort:
    # can accept Zipkin spans in JSON or Thrift
    zipkin: {}
      # port: 9411
      # nodePort:
    otlp:
      grpc: {}
        # port: 4317
        # nodePort:
      http: {}
        # port: 4318
        # nodePort:
  ingress:
    enabled: false
  resources:
    limits:
      cpu: 1
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi
  serviceAccount:
    create: true
    automountServiceAccountToken: false
    name:
    annotations: {}
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
  podAnnotations: {}
  podLabels: {}
%{ if var.elasticsearch_strategy == "ES_ECK_OPERATOR" ~}
  extraSecretMounts:
  - name: jaeger-tls
    mountPath: /tls
    secretName: ${local.elasticsearch_certificates_k8s_secret_name}
    readOnly: true
%{ else ~}
  extraSecretMounts: {}
%{ endif ~}
  extraConfigmapMounts: []
  priorityClassName: ""
  serviceMonitor:
    enabled: true
    additionalLabels: {}
    relabelings: []
    metricRelabelings: []

query:
  enabled: true
  basePath: "${var.jaeger_path}"
  oAuthSidecar:
    enabled: false
    containerPort: 4180
    args: []
    extraEnv: []
    extraConfigmapMounts: []
    extraSecretMounts: []
  # config: |-
  #   provider = "oidc"
  #   https_address = ":4180"
  #   upstreams = ["http://localhost:16686"]
  #   redirect_url = "https://jaeger-svc-domain/oauth2/callback"
  #   client_id = "jaeger-query"
  #   oidc_issuer_url = "https://keycloak-svc-domain/auth/realms/Default"
  #   cookie_secure = "true"
  #   email_domains = "*"
  #   oidc_groups_claim = "groups"
  #   user_id_claim = "preferred_username"
  #   skip_provider_button = "true"
  podSecurityContext: {}
  securityContext: {}
  agentSidecar:
    enabled: true
#    resources:
#      limits:
#        cpu: 500m
#        memory: 512Mi
#      requests:
#        cpu: 256m
#        memory: 128Mi
  annotations: {}
  dnsPolicy: ClusterFirst
%{ if var.elasticsearch_strategy == "ES_ECK_OPERATOR" ~}
  cmdlineParams:
    es.tls.enabled: "true"
    es.tls.ca: "/tls/ca.crt"
    # need to fallback ES client to ES 7 level since Jaeger cannot work with ES 8 out of the box
    es.version: 7
    es.create-index-templates: "false"
%{ else ~}
  cmdlineParams: {}
%{ endif ~}
  extraEnv: []
  replicaCount: 1
  service:
    annotations: {}
    type: ClusterIP
    # List of IP ranges that are allowed to access the load balancer (if supported)
    loadBalancerSourceRanges: []
    port: 80
    # Specify a custom target port (e.g. port of auth proxy)
    # targetPort: 8080
    # Specify a specific node port when type is NodePort
    # nodePort: 32500
  ingress:
    enabled: true
    ingressClassName: ${var.ingress_class_name}
    annotations: {}
    labels: {}
    # Used to create an Ingress record.
    hosts:
      - "${var.jaeger_host_name}"
    health:
      exposed: false
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
       cpu: 256m
       memory: 128Mi
  serviceAccount:
    create: true
    # Explicitly mounts the API credentials for the Service Account
    automountServiceAccountToken: false
    name:
    annotations: {}
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
  podAnnotations: {}
  podLabels: {}
  extraConfigmapMounts: []
%{ if var.elasticsearch_strategy == "ES_ECK_OPERATOR" ~}
  extraSecretMounts:
  - name: jaeger-tls
    mountPath: /tls
    secretName: ${local.elasticsearch_certificates_k8s_secret_name}
    readOnly: true
%{ else ~}
  extraSecretMounts: []
%{ endif ~}
  extraVolumes: []
  sidecars: []
  priorityClassName: ""
  serviceMonitor:
    enabled: true

esIndexCleaner:
  enabled: false
  securityContext:
    runAsUser: 1000
  podSecurityContext:
    runAsUser: 1000
  annotations: {}
  cmdlineParams: {}
  extraEnv: []
  schedule: "55 23 * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  concurrencyPolicy: Forbid
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 256m
      memory: 128Mi
  numberOfDays: 7
  serviceAccount:
    create: true
    # Explicitly mounts the API credentials for the Service Account
    automountServiceAccountToken: false
    name:
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
  extraSecretMounts: []
  extraConfigmapMounts: []
  podAnnotations: {}
  podLabels: {}
  # ttlSecondsAfterFinished: 120

esRollover:
  enabled: false
  securityContext: {}
  podSecurityContext:
    runAsUser: 1000
  annotations: {}
  image: jaegertracing/jaeger-es-rollover
  imagePullSecrets: []
  tag: latest
  pullPolicy: Always
  cmdlineParams: {}
  extraEnv:
    - name: CONDITIONS
      value: '{"max_age": "1d"}'
  schedule: "10 0 * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  concurrencyPolicy: Forbid
  resources: {}
    # limits:
    #   cpu: 500m
    #   memory: 512Mi
    # requests:
    #   cpu: 256m
    #   memory: 128Mi
  serviceAccount:
    create: true
    automountServiceAccountToken: false
    name:
  nodeSelector: {}
  tolerations: []
  affinity: {}
  extraSecretMounts: []
  extraConfigmapMounts: []
  podAnnotations: {}
  podLabels: {}
  # ttlSecondsAfterFinished: 120
  initHook:
    extraEnv: []
      # - name: SHARDS
      #   value: "3"
    annotations: {}
    podAnnotations: {}
    podLabels: {}
    ttlSecondsAfterFinished: 120

esLookback:
  enabled: false
  securityContext: {}
  podSecurityContext:
    runAsUser: 1000
  annotations: {}
  image: jaegertracing/jaeger-es-rollover
  imagePullSecrets: []
  tag: latest
  pullPolicy: Always
  cmdlineParams: {}
  extraEnv:
    - name: UNIT
      value: days
    - name: UNIT_COUNT
      value: '7'
  schedule: '5 0 * * *'
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  concurrencyPolicy: Forbid
  resources: {}
    # limits:
    #   cpu: 500m
    #   memory: 512Mi
    # requests:
    #   cpu: 256m
    #   memory: 128Mi
  serviceAccount:
    create: true
    # Explicitly mounts the API credentials for the Service Account
    automountServiceAccountToken: false
    name:
  nodeSelector: {}
  tolerations: []
  affinity: {}
  extraSecretMounts: []
  extraConfigmapMounts: []
  podAnnotations: {}
  ## Additional pod labels
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  podLabels: {}
  # ttlSecondsAfterFinished: 120
# End: Default values for the various components of Jaeger

hotrod:
  enabled: false

extraObjects: []
EOT
}

resource helm_release jaeger {
  chart = "jaeger"
  version = "0.69.1"
  name = "trace-jaeger"
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  namespace = kubernetes_namespace.namespace.metadata[0].name
  repository = "https://jaegertracing.github.io/helm-charts"
  values = [ local.helm_values ]
}