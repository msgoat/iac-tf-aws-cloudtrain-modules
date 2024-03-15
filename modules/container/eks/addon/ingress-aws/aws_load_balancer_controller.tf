locals {
  helm_chart_name        = "aws-load-balancer-controller"
  actual_replica_count   = var.ensure_high_availability && var.replica_count < 2 ? 2 : var.replica_count
  controller_values      = <<EOT
# Default values for aws-load-balancer-controller.
replicaCount: ${local.actual_replica_count}
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "${aws_iam_role.controller.arn}"

rbac:
  create: true

podSecurityContext:
  fsGroup: 65534

securityContext:
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  allowPrivilegeEscalation: false

terminationGracePeriodSeconds: 10

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

priorityClassName: system-cluster-critical

nodeSelector: {}

tolerations: []

affinity: {}

configureDefaultAffinity: true

%{if var.ensure_high_availability~}
topologySpreadConstraints:
- labelSelector:
    matchLabels:
      app.kubernetes.io/name: ${local.helm_chart_name}
      app.kubernetes.io/instance: ${var.helm_release_name}
  topologyKey: topology.kubernetes.io/zone
  maxSkew: 1
  whenUnsatisfiable: ScheduleAnyway
- labelSelector:
    matchLabels:
      app.kubernetes.io/name: ${local.helm_chart_name}
      app.kubernetes.io/instance: ${var.helm_release_name}
  topologyKey: kubernetes.io/hostname
  maxSkew: 1
  whenUnsatisfiable: ScheduleAnyway
%{else~}
topologySpreadConstraints: []
%{endif~}

updateStrategy: {}

serviceAnnotations: {}

deploymentAnnotations: {}

podAnnotations: {}

podLabels: {}

additionalLabels: {}

enableCertManager: ${var.cert_manager_enabled}

clusterName: ${var.eks_cluster_name}

cluster:
  dnsDomain: cluster.local

ingressClass: ${var.kubernetes_ingress_class_name}

ingressClassParams:
  create: true
  # The name of ingressClassParams resource will be referred in ingressClass
  name:
  spec: {}

createIngressClassResource: true

region: ${var.region_name}

defaultTargetType: ip

enablePodReadinessGateInject: true

enableShield: false

enableWaf: false

enableWafv2: false

logLevel: info

metricsBindAddr: ""

webhookBindPort:

keepTLSSecret: false

livenessProbe:
  failureThreshold: 2
  httpGet:
    path: /healthz
    port: 61779
    scheme: HTTP
  initialDelaySeconds: 30
  timeoutSeconds: 10

%{if local.actual_replica_count > 1 ~}
podDisruptionBudget:
  maxUnavailable: 1
%{endif~}

externalManagedTags: []

# enableEndpointSlices enables k8s EndpointSlices for IP targets instead of Endpoints (default false)
enableEndpointSlices:

enableBackendSecurityGroup: true

backendSecurityGroup:

disableRestrictedSecurityGroupRules:

controllerConfig:
  featureGates:
    SubnetsClusterTagCheck: false

serviceMonitor:
  enabled: ${var.prometheus_operator_enabled}

clusterSecretsPermissions:
  allowAllSecrets: false

ingressClassConfig:
  default: ${var.kubernetes_default_ingress_class}
EOT
}

resource "helm_release" "controller" {
  chart             = local.helm_chart_name
  repository        = "https://aws.github.io/eks-charts"
  name              = var.helm_release_name
  version           = var.helm_chart_version
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  namespace         = var.kubernetes_namespace_owned ? kubernetes_namespace_v1.this[0].metadata[0].name : var.kubernetes_namespace_name
  create_namespace  = true
  values            = [local.controller_values]
  depends_on        = [aws_iam_role_policy_attachment.controller]
}