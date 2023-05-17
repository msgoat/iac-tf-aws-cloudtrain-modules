locals {
  nginx_values = <<EOT
ingress:
%{ if var.load_balancer_strategy == "INGRESS_VIA_ALB" ~}
  enabled: true
  class: alb
  host: ${var.host_name}
  service:
    name: ingress-nginx-controller
loadbalancer:
  name: ${local.alb_name}
  tls:
    certificateArn: ${var.tls_certificate_arn}
  targetGroupSubnets: ${join(",", var.target_group_subnet_ids)}
%{ else ~}
  enabled: false
%{ endif ~}

targetGroupBinding:
%{ if var.load_balancer_strategy == "SERVICE_VIA_TARGET_GROUP_BINDING" ~}
  enabled: true
  targetGroupArn: ${var.target_group_arn}
  service:
    name: ingress-nginx-controller
    port: 80
%{ else ~}
  enabled: false
%{ endif ~}

# upstream chart configuration
ingress-nginx:
  ## nginx configuration
  ## Ref: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/index.md

  commonLabels: {}

  controller:
    name: controller
    image:
      runAsUser: 101
      allowPrivilegeEscalation: true
    containerPort:
      http: 80
      https: 443
%{ if var.jaeger_enabled ~}
    config:
      enabled-opentracing: true
      jaeger-collector-host: ${var.jaeger_agent_host}
      jaeger-collector-port: ${var.jaeger_agent_port}
%{ else  ~}
    config: {}
%{ endif ~}
    configAnnotations: {}
    proxySetHeaders: {}
    addHeaders: {}
    dnsConfig: {}
    hostname: {}
    dnsPolicy: ClusterFirst
    reportNodeInternalIp: false
    watchIngressWithoutClass: false
    ingressClassByName: false
    enableTopologyAwareRouting: false
    allowSnippetAnnotations: true
    hostNetwork: false
    hostPort:
      enabled: false
    ingressClassResource:
      name: nginx
      enabled: true
      default: ${var.default_ingress_class}
      controllerValue: "k8s.io/ingress-nginx"
      parameters: {}
    ingressClass: nginx
    podLabels: {}
    podSecurityContext: {}
    sysctls: {}
    publishService:
      enabled: true
    scope:
      enabled: false
    configMapNamespace: ""
    extraArgs: {}
    ## extraArgs:
    ##   default-ssl-certificate: "<namespace>/<secret_name>"
    extraEnvs: []
    kind: Deployment
    annotations: {}
    labels: {}
    updateStrategy: {}
    minReadySeconds: 0
    tolerations: []
    affinity: {}
    topologySpreadConstraints: []
    terminationGracePeriodSeconds: 300
    nodeSelector:
      kubernetes.io/os: linux
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
    replicaCount: ${var.replica_count}
%{ if var.replica_count > 1 ~}
    maxUnavailable: 1
%{ endif ~}
    resources:
      requests:
        cpu: 100m
        memory: 90Mi
    autoscaling:
      apiVersion: autoscaling/v2
      enabled: false
    enableMimalloc: true
    service:
      enabled: true
      appProtocol: true
%{ if var.load_balancer_strategy == "SERVICE_VIA_NLB" ~}
      annotations:
        "service.beta.kubernetes.io/aws-load-balancer-name": "nlb-${var.region_name}-${var.solution_fqn}-eks"
        "service.beta.kubernetes.io/aws-load-balancer-type": "internal"
        "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "ip"
        "service.beta.kubernetes.io/aws-load-balancer-alpn-policy": "HTTP2Preferred"
        "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": ${var.tls_certificate_arn}
        "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy": "ELBSecurityPolicy-TLS13-1-2-2021-06"
        "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "tcp"
%{ else ~}
      annotations: {}
%{ endif ~}
      labels: {}
      externalIPs: []
      loadBalancerIP: ""
      loadBalancerSourceRanges: []
      enableHttp: true
      enableHttps: true
      # healthCheckNodePort: 0
      ipFamilyPolicy: "SingleStack"
      ipFamilies:
        - IPv4
      ports:
        http: 80
        https: 443
      targetPorts:
        http: http
        https: https
%{ if var.load_balancer_strategy == "SERVICE_VIA_NODE_PORT" ~}
      type: NodePort
      nodePorts:
        http: 32080
        https: 32443
%{ endif ~}
%{ if var.load_balancer_strategy == "SERVICE_VIA_NLB" ~}
      type: LoadBalancer
%{ endif ~}
%{ if var.load_balancer_strategy == "INGRESS_VIA_ALB" || var.load_balancer_strategy == "SERVICE_VIA_TARGET_GROUP_BINDING" ~}
      type: ClusterIP
%{ endif ~}
      external:
        enabled: true
      internal:
        enabled: false
    shareProcessNamespace: false
    extraContainers: []
    extraVolumeMounts: []
    extraVolumes: []
    extraInitContainers: []
    extraModules: []
    # - name: mytestmodule
    #   image: registry.k8s.io/ingress-nginx/mytestmodule
    #   containerSecurityContext:
    #     allowPrivilegeEscalation: false

    opentelemetry:
      enabled: false

    admissionWebhooks:
      annotations: {}
      enabled: true
      extraEnvs: []
      failurePolicy: Fail
      # timeoutSeconds: 10
      port: 8443
      certificate: "/usr/local/certificates/cert"
      key: "/usr/local/certificates/key"
      namespaceSelector: {}
      objectSelector: {}
      labels: {}
      existingPsp: ""
      networkPolicyEnabled: false
      service:
        annotations: {}
        externalIPs: []
        loadBalancerSourceRanges: []
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
        image:
        priorityClassName: ""
        podAnnotations: {}
        nodeSelector:
          kubernetes.io/os: linux
        tolerations: []
        labels: {}
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
        annotations: {}
        labels: {}
        externalIPs: []
        loadBalancerSourceRanges: []
        servicePort: 10254
        type: ClusterIP
      serviceMonitor:
        enabled: ${var.prometheus_operator_enabled}
      prometheusRule:
        enabled: false
    lifecycle:
      preStop:
        exec:
          command:
            - /wait-shutdown
    priorityClassName: ""
  revisionHistoryLimit: 10

  defaultBackend:
    enabled: true
    name: defaultbackend
    image:
      runAsUser: 65534
      runAsNonRoot: true
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
    existingPsp: ""
    extraArgs: {}
    serviceAccount:
      create: true
      name: ""
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
    tolerations: []
    affinity: {}
    podSecurityContext: {}
    containerSecurityContext: {}
    podLabels: {}
    nodeSelector:
      kubernetes.io/os: linux
    podAnnotations: {}
    replicaCount: ${var.replica_count}
%{ if var.replica_count > 1 ~}
    maxUnavailable: 1
%{ endif ~}
    resources: {}
    # limits:
    #   cpu: 10m
    #   memory: 20Mi
    # requests:
    #   cpu: 10m
    #   memory: 20Mi
    extraVolumeMounts: []
    extraVolumes: []
    autoscaling:
      apiVersion: autoscaling/v2
      annotations: {}
      enabled: false
      minReplicas: 1
      maxReplicas: 2
      targetCPUUtilizationPercentage: 50
      targetMemoryUtilizationPercentage: 50
    service:
      annotations: {}
      # clusterIP: ""
      externalIPs: []
      loadBalancerSourceRanges: []
      servicePort: 80
      type: ClusterIP
    priorityClassName: ""
    labels: {}
  rbac:
    create: true
    scope: false
  podSecurityPolicy:
    enabled: false
  serviceAccount:
    create: true
    name: ""
    automountServiceAccountToken: true
    # -- Annotations for the controller service account
    annotations: {}
  tcp: {}
  udp: {}
  portNamePrefix: ""
  dhParam: ""
EOT
}

resource helm_release nginx {
  chart = "${path.module}/resources/helm/nginx-aws"
  name = var.helm_release_name
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  wait = true
  create_namespace = false
  namespace = kubernetes_namespace_v1.nginx.metadata[0].name
  values = [ local.nginx_values ]
  depends_on = [ kubernetes_namespace_v1.nginx ]
}