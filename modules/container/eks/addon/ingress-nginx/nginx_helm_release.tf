locals {
  actual_replica_count = var.ensure_high_availability && var.replica_count < 2 ? 2 : var.replica_count
  nginx_values         = <<EOT
## nginx configuration
## Ref: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/index.md

controller:
  name: controller
  enableAnnotationValidations: false
  image:
    runAsUser: 101
    allowPrivilegeEscalation: true
  containerPort:
    http: 80
    https: 443
  config:
    use-forwarded-headers: true # mandatory when behind a load balancer
    proxy-add-original-uri-header: true # mandatory for URL rewrites
    enable-opentracing: false
    enable-opentelemetry: true
    opentelemetry-config: "/etc/nginx/opentelemetry.toml"
    opentelemetry-operation-name: "HTTP $request_method $service_name $uri"
    opentelemetry-trust-incoming-span: "true"
    otlp-collector-host: ${var.opentelemetry_collector_host}
    otlp-collector-port: "${var.opentelemetry_collector_port}"
    otel-max-queuesize: "2048"
    otel-schedule-delay-millis: "5000"
    otel-max-export-batch-size: "512"
    otel-service-name: "${var.helm_release_name}" # Opentelemetry resource name
    otel-sampler: "AlwaysOn" # Also: AlwaysOff, TraceIdRatioBased
    otel-sampler-ratio: "1.0"
    otel-sampler-parent-based: "false"
  enableTopologyAwareRouting: false
  allowSnippetAnnotations: true
  hostNetwork: false
  ingressClassResource:
    default: ${var.kubernetes_default_ingress_class}
  ingressClass: ${var.kubernetes_ingress_class_name}
  podSecurityContext: {}
  sysctls: {}
  publishService:
    enabled: true
  extraArgs: {}
  ## extraArgs:
  ##   default-ssl-certificate: "<namespace>/<secret_name>"
  extraEnvs: []
%{if var.node_group_workload_class != ""~}
  # It's OK to be deployed to the tools node group, too
  tolerations:
    - key: "group.msg.cloud.kubernetes/workload"
      operator: "Equal"
      value: ${var.node_group_workload_class}
      effect: "NoSchedule"
%{endif~}
%{if var.node_group_workload_class != ""~}
  affinity:
    # Encourages deployment to the tools node group
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: "group.msg.cloud.kubernetes/workload"
                operator: In
                values:
                  - ${var.node_group_workload_class}
%{endif~}
%{if var.ensure_high_availability~}
  topologySpreadConstraints:
    - labelSelector:
        matchLabels:
          app.kubernetes.io/name: '{{ include "ingress-nginx.name" . }}'
          app.kubernetes.io/instance: '{{ .Release.Name }}'
          app.kubernetes.io/component: controller
      topologyKey: topology.kubernetes.io/zone
      maxSkew: 1
      whenUnsatisfiable: ScheduleAnyway
    - labelSelector:
        matchLabels:
          app.kubernetes.io/name: '{{ include "ingress-nginx.name" . }}'
          app.kubernetes.io/instance: '{{ .Release.Name }}'
          app.kubernetes.io/component: controller
      topologyKey: kubernetes.io/hostname
      maxSkew: 1
      whenUnsatisfiable: ScheduleAnyway
%{else~}
  topologySpreadConstraints: []
%{endif~}
  terminationGracePeriodSeconds: 300
  startupProbe:
    httpGet:
      path: "/healthz"
      port: 10254
      scheme: HTTP
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 2
    successThreshold: 1
    failureThreshold: 5
  livenessProbe:
    httpGet:
      path: "/healthz"
      port: 10254
      scheme: HTTP
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 5
  readinessProbe:
    httpGet:
      path: "/healthz"
      port: 10254
      scheme: HTTP
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 3
  healthCheckPath: "/healthz"
  healthCheckHost: ""
  podAnnotations: {}
  replicaCount: ${local.actual_replica_count}
%{if local.actual_replica_count > 1~}
  maxUnavailable: 1
%{endif~}
  resources:
    requests:
      cpu: 100m
      memory: 90Mi
  autoscaling:
    apiVersion: autoscaling/v2
    enabled: false
  service:
    enabled: true
    appProtocol: true
%{if var.load_balancer_strategy == "SERVICE_VIA_NLB"~}
    annotations:
      "service.beta.kubernetes.io/aws-load-balancer-name": "nlb-${var.region_name}-${var.solution_fqn}-eks"
      "service.beta.kubernetes.io/aws-load-balancer-type": "internal"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "ip"
      "service.beta.kubernetes.io/aws-load-balancer-alpn-policy": "HTTP2Preferred"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": ${var.tls_certificate_arn}
      "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy": "ELBSecurityPolicy-TLS13-1-2-2021-06"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "tcp"
%{else~}
    annotations: {}
%{endif~}
    labels: {}
    enableHttp: true
    enableHttps: true
    ipFamilyPolicy: "SingleStack"
    ipFamilies:
      - IPv4
    ports:
      http: 80
      https: 443
    targetPorts:
      http: http
      https: https
%{if var.load_balancer_strategy == "SERVICE_VIA_NODE_PORT"~}
    type: NodePort
    nodePorts:
      http: 32080
      https: 32443
%{endif~}
%{if var.load_balancer_strategy == "SERVICE_VIA_NLB"~}
    type: LoadBalancer
%{endif~}
%{if var.load_balancer_strategy == "INGRESS_VIA_ALB" || var.load_balancer_strategy == "SERVICE_VIA_TARGET_GROUP_BINDING"~}
    type: ClusterIP
%{endif~}
    external:
      enabled: true
    internal:
      enabled: false
  shareProcessNamespace: false

  opentelemetry:
    enabled: true

  admissionWebhooks:
    enabled: true
    extraEnvs: []
    failurePolicy: Fail
    # timeoutSeconds: 10
    port: 8443
    certificate: "/usr/local/certificates/cert"
    key: "/usr/local/certificates/key"
    networkPolicyEnabled: false
    service:
      servicePort: 443
      type: ClusterIP
    createSecretJob:
      securityContext:
        allowPrivilegeEscalation: false
      resources: {}
      # requests:
      #   cpu: 10m
      #   memory: 20Mi
    patchWebhookJob:
      securityContext:
        allowPrivilegeEscalation: false
      resources: {}
    patch:
      enabled: true
      securityContext:
        runAsNonRoot: true
        runAsUser: 2000
        fsGroup: 2000
    certManager:
      enabled: ${var.cert_manager_enabled}
      rootCert:
        # default to be 5y
        duration: ""
      admissionCert:
        # default to be 1y
        duration: ""
        # issuerRef:
        #   name: "issuer"
        #   kind: "ClusterIssuer"
  metrics:
    port: 10254
    portName: metrics
    enabled: ${var.prometheus_operator_enabled}
    service:
      servicePort: 10254
      type: ClusterIP
    serviceMonitor:
      enabled: ${var.prometheus_operator_enabled}

revisionHistoryLimit: 10

defaultBackend:
  enabled: true
  name: defaultbackend
  image:
    runAsUser: 65534
    runAsNonRoot: true
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
  extraArgs: {}
  serviceAccount:
    create: true
    automountServiceAccountToken: true
  extraEnvs: []
  port: 8080
  livenessProbe:
    failureThreshold: 3
    initialDelaySeconds: 30
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
  readinessProbe:
    failureThreshold: 6
    initialDelaySeconds: 0
    periodSeconds: 5
    successThreshold: 1
    timeoutSeconds: 5
  minReadySeconds: 0
  replicaCount: ${local.actual_replica_count}
%{if local.actual_replica_count > 1~}
  maxUnavailable: 1
%{endif~}
  resources:
    limits:
      cpu: 10m
      memory: 20Mi
    requests:
      cpu: 10m
      memory: 20Mi
%{if var.node_group_workload_class != ""~}
  # It's OK to be deployed to the tools node group, too
  tolerations:
    - key: "group.msg.cloud.kubernetes/workload"
      operator: "Equal"
      value: ${var.node_group_workload_class}
      effect: "NoSchedule"
%{endif~}
%{if var.node_group_workload_class != ""~}
  affinity:
    # Encourages deployment to the tools node group
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: "group.msg.cloud.kubernetes/workload"
                operator: In
                values:
                  - ${var.node_group_workload_class}
%{endif~}
%{if var.ensure_high_availability~}
  topologySpreadConstraints:
    - labelSelector:
        matchLabels:
          app.kubernetes.io/name: '{{ include "ingress-nginx.name" . }}'
          app.kubernetes.io/instance: '{{ .Release.Name }}'
          app.kubernetes.io/component: default-backend
      topologyKey: topology.kubernetes.io/zone
      maxSkew: 1
      whenUnsatisfiable: ScheduleAnyway
    - labelSelector:
        matchLabels:
          app.kubernetes.io/name: '{{ include "ingress-nginx.name" . }}'
          app.kubernetes.io/instance: '{{ .Release.Name }}'
          app.kubernetes.io/component: default-backend
      topologyKey: kubernetes.io/hostname
      maxSkew: 1
      whenUnsatisfiable: ScheduleAnyway
%{else~}
  topologySpreadConstraints: []
%{endif~}
  autoscaling:
    apiVersion: autoscaling/v2
    annotations: {}
    enabled: false
    minReplicas: 1
    maxReplicas: 2
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50
  service:
    servicePort: 80
    type: ClusterIP

rbac:
  create: true
  scope: false

podSecurityPolicy:
  enabled: false

serviceAccount:
  create: true
  automountServiceAccountToken: true
  annotations: {}
EOT
}

resource "helm_release" "nginx" {
  chart             = "ingress-nginx"
  repository        = "https://kubernetes.github.io/ingress-nginx"
  version           = var.helm_chart_version
  name              = var.helm_release_name
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  wait              = true
  create_namespace  = false
  namespace         = kubernetes_namespace_v1.nginx.metadata[0].name
  values            = [local.nginx_values]
  depends_on        = [kubernetes_namespace_v1.nginx]
}