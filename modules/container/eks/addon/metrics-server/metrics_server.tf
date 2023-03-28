locals {
  metrics_server_values = <<EOT
# Default values for metrics-server.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

nameOverride: ""
fullnameOverride: ""

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""
  # The list of secrets mountable by this service account.
  # See https://kubernetes.io/docs/reference/labels-annotations-taints/#enforce-mountable-secrets
  secrets: []

rbac:
  # Specifies whether RBAC resources should be created
  create: true
  pspEnabled: false

apiService:
  # Specifies if the v1beta1.metrics.k8s.io API service should be created.
  #
  # You typically want this enabled! If you disable API service creation you have to
  # manage it outside of this chart for e.g horizontal pod autoscaling to
  # work with this release.
  create: true
  # Annotations to add to the API service
  annotations: {}
  # Specifies whether to skip TLS verification
  insecureSkipTLSVerify: true
  # The PEM encoded CA bundle for TLS verification
  caBundle: ""

commonLabels: {}
podLabels: {}
podAnnotations: {}

podSecurityContext: {}

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000

priorityClassName: system-cluster-critical

containerPort: 10250

hostNetwork:
  # Specifies if metrics-server should be started in hostNetwork mode.
  #
  # You would require this enabled if you use alternate overlay networking for pods and
  # API server unable to communicate with metrics-server. As an example, this is required
  # if you use Weave network on EKS
  enabled: false

replicas: 2

updateStrategy: {}
#   type: RollingUpdate
#   rollingUpdate:
#     maxSurge: 0
#     maxUnavailable: 1

podDisruptionBudget:
  # https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  enabled: false
  minAvailable:
  maxUnavailable:

defaultArgs:
  - --cert-dir=/tmp
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-use-node-status-port
  - --metric-resolution=15s

args: []

livenessProbe:
  httpGet:
    path: /livez
    port: https
    scheme: HTTPS
  initialDelaySeconds: 0
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /readyz
    port: https
    scheme: HTTPS
  initialDelaySeconds: 20
  periodSeconds: 10
  failureThreshold: 3

service:
  type: ClusterIP
  port: 443
  annotations: {}
  labels: {}
  #  Add these labels to have metrics-server show up in `kubectl cluster-info`
  #  kubernetes.io/cluster-service: "true"
  #  kubernetes.io/name: "Metrics-server"

addonResizer:
  enabled: false

metrics:
  enabled: false

serviceMonitor:
  enabled: false
  additionalLabels: {}
  interval: 1m
  scrapeTimeout: 10s
  metricRelabelings: []
  relabelings: []

# See https://github.com/kubernetes-sigs/metrics-server#scaling
resources: {}

extraVolumeMounts: []

extraVolumes: []

nodeSelector: {}

tolerations: []

affinity: {}

topologySpreadConstraints: []

# Annotations to add to the deployment
deploymentAnnotations: {}

schedulerName: ""
EOT
}

resource "helm_release" "metrics_server" {
  chart             = "metrics-server"
  repository        = "https://kubernetes-sigs.github.io/metrics-server/"
  name              = var.helm_release_name
  version           = var.helm_chart_version
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  namespace         = var.kubernetes_namespace_name
  values            = [ local.metrics_server_values ]
}