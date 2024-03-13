locals {
  actual_replica_count = var.ensure_high_availability && var.replica_count < 2 ? 2 : var.replica_count
  helm_chart_name      = "cert-manager"
  cert_manager_values  = <<EOT
# Default values for cert-manager.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
global:
  # Reference to one or more secrets to be used when pulling images
  # ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  imagePullSecrets: []
  # - name: "image-pull-secret"

  # Labels to apply to all resources
  # Please note that this does not add labels to the resources created dynamically by the controllers.
  # For these resources, you have to add the labels in the template in the cert-manager custom resource:
  # eg. podTemplate/ ingressTemplate in ACMEChallengeSolverHTTP01Ingress
  #    ref: https://cert-manager.io/docs/reference/api-docs/#acme.cert-manager.io/v1.ACMEChallengeSolverHTTP01Ingress
  # eg. secretTemplate in CertificateSpec
  #    ref: https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec
  commonLabels: {}
  # team_name: dev

  # Optional priority class to be used for the cert-manager pods
  priorityClassName: ""
  rbac:
    create: true
    # Aggregate ClusterRoles to Kubernetes default user-facing roles. Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
    aggregateClusterRoles: true

  podSecurityPolicy:
    enabled: false
    useAppArmor: true

  # Set the verbosity of cert-manager. Range of 0 - 6 with 6 being the most verbose.
  logLevel: 2

  leaderElection:
    # Override the namespace used for the leader election lease
    namespace: "${var.kubernetes_namespace_name}"

    # The duration that non-leader candidates will wait after observing a
    # leadership renewal until attempting to acquire leadership of a led but
    # unrenewed leader slot. This is effectively the maximum duration that a
    # leader can be stopped before it is replaced by another candidate.
    # leaseDuration: 60s

    # The interval between attempts by the acting master to renew a leadership
    # slot before it stops leading. This must be less than or equal to the
    # lease duration.
    # renewDeadline: 40s

    # The duration the clients should wait between attempting acquisition and
    # renewal of a leadership.
    # retryPeriod: 15s

installCRDs: true

replicaCount: ${local.actual_replica_count}

strategy: {}
  # type: RollingUpdate
  # rollingUpdate:
  #   maxSurge: 0
  #   maxUnavailable: 1

%{ if local.actual_replica_count > 1 ~}
podDisruptionBudget:
  enabled: true
  minAvailable:
  maxUnavailable: 1
%{ endif ~}

# Comma separated list of feature gates that should be enabled on the
# controller pod & webhook pod.
featureGates: ""

# The maximum number of challenges that can be scheduled as 'processing' at once
maxConcurrentChallenges: 60

# Override the namespace used to store DNS provider credentials etc. for ClusterIssuer
# resources. By default, the same namespace as cert-manager is deployed within is
# used. This namespace will not be automatically created by the Helm chart.
clusterResourceNamespace: ""

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  # name: ""
  # Optional additional annotations to add to the controller's ServiceAccount
  annotations:
    eks.amazonaws.com/role-arn: "${aws_iam_role.cert_manager.arn}"

  # Automount API credentials for a Service Account.
  # Optional additional labels to add to the controller's ServiceAccount
  # labels: {}
  automountServiceAccountToken: true

# Automounting API credentials for a particular pod
# automountServiceAccountToken: true

# When this flag is enabled, secrets will be automatically removed when the certificate resource is deleted
enableCertificateOwnerRef: false

# Setting Nameservers for DNS01 Self Check
# See: https://cert-manager.io/docs/configuration/acme/dns01/#setting-nameservers-for-dns01-self-check

# Comma separated string with host and port of the recursive nameservers cert-manager should query
dns01RecursiveNameservers: ""

# Forces cert-manager to only use the recursive nameservers for verification.
# Enabling this option could cause the DNS01 self check to take longer due to caching performed by the recursive nameservers
dns01RecursiveNameserversOnly: false

# Additional command line flags to pass to cert-manager controller binary.
# To see all available flags run docker run quay.io/jetstack/cert-manager-controller:<version> --help
extraArgs: []
  # Use this flag to enable or disable arbitrary controllers, for example, disable the CertificiateRequests approver
  # - --controllers=*,-certificaterequests-approver

extraEnv: []
# - name: SOME_VAR
#   value: 'some value'

resources: {}
  # requests:
  #   cpu: 10m
  #   memory: 32Mi

# Pod Security Context
# ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
securityContext:
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault

# Container Security Context to be set on the controller component container
# ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
containerSecurityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true


volumes: []

volumeMounts: []

# Optional additional annotations to add to the controller Deployment
# deploymentAnnotations: {}

# Optional additional annotations to add to the controller Pods
# podAnnotations: {}

podLabels: {}

# Optional annotations to add to the controller Service
# serviceAnnotations: {}

# Optional additional labels to add to the controller Service
# serviceLabels: {}

# Optional DNS settings, useful if you have a public and private DNS zone for
# the same domain on Route 53. What follows is an example of ensuring
# cert-manager can access an ingress or DNS TXT records at all times.
# NOTE: This requires Kubernetes 1.10 or `CustomPodDNS` feature gate enabled for
# the cluster to work.
# podDnsPolicy: "None"
# podDnsConfig:
#   nameservers:
#     - "1.1.1.1"
#     - "8.8.8.8"

nodeSelector:
  kubernetes.io/os: linux

ingressShim: {}
  # defaultIssuerName: ""
  # defaultIssuerKind: ""
  # defaultIssuerGroup: ""

prometheus:
  enabled: ${var.prometheus_operator_enabled}
  servicemonitor:
    enabled: ${var.prometheus_operator_enabled}
    prometheusInstance: default
    targetPort: 9402
    path: /metrics
    interval: 60s
    scrapeTimeout: 30s
    labels: {}
    annotations: {}
    honorLabels: false

# expects input structure as per specification https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#affinity-v1-core
# for example:
#   affinity:
#     nodeAffinity:
#      requiredDuringSchedulingIgnoredDuringExecution:
#        nodeSelectorTerms:
#        - matchExpressions:
#          - key: foo.bar.com/role
#            operator: In
#            values:
#            - master
affinity: {}

# expects input structure as per specification https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#toleration-v1-core
# for example:
#   tolerations:
#   - key: foo.bar.com/role
#     operator: Equal
#     value: master
#     effect: NoSchedule
tolerations: []

%{if var.ensure_high_availability~}
topologySpreadConstraints:
- labelSelector:
    matchLabels:
      app.kubernetes.io/name: ${local.helm_chart_name}
      app.kubernetes.io/instance: ${var.helm_release_name}
      app.kubernetes.io/component: "controller"
  topologyKey: topology.kubernetes.io/zone
  maxSkew: 1
  whenUnsatisfiable: ScheduleAnyway
- labelSelector:
    matchLabels:
      app.kubernetes.io/name: ${local.helm_chart_name}
      app.kubernetes.io/instance: ${var.helm_release_name}
      app.kubernetes.io/component: "controller"
  topologyKey: kubernetes.io/hostname
  maxSkew: 1
  whenUnsatisfiable: ScheduleAnyway
%{else~}
topologySpreadConstraints: []
%{endif~}

webhook:
  replicaCount: 1
  timeoutSeconds: 10

  # Used to configure options for the webhook pod.
  # This allows setting options that'd usually be provided via flags.
  # An APIVersion and Kind must be specified in your values.yaml file.
  # Flags will override options that are set here.
  config:
    # apiVersion: webhook.config.cert-manager.io/v1alpha1
    # kind: WebhookConfiguration

    # The port that the webhook should listen on for requests.
    # In GKE private clusters, by default kubernetes apiservers are allowed to
    # talk to the cluster nodes only on 443 and 10250. so configuring
    # securePort: 10250, will work out of the box without needing to add firewall
    # rules or requiring NET_BIND_SERVICE capabilities to bind port numbers <1000.
    # This should be uncommented and set as a default by the chart once we graduate
    # the apiVersion of WebhookConfiguration past v1alpha1.
    # securePort: 10250

  strategy: {}
    # type: RollingUpdate
    # rollingUpdate:
    #   maxSurge: 0
    #   maxUnavailable: 1

  # Pod Security Context to be set on the webhook component Pod
  # ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault

  podDisruptionBudget:
    enabled: false

    minAvailable: 1
    # maxUnavailable: 1

    # minAvailable and maxUnavailable can either be set to an integer (e.g. 1)
    # or a percentage value (e.g. 25%)

  # Container Security Context to be set on the webhook component container
  # ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  containerSecurityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true

  # Optional additional annotations to add to the webhook Deployment
  # deploymentAnnotations: {}

  # Optional additional annotations to add to the webhook Pods
  # podAnnotations: {}

  # Optional additional annotations to add to the webhook Service
  # serviceAnnotations: {}

  # Optional additional annotations to add to the webhook MutatingWebhookConfiguration
  # mutatingWebhookConfigurationAnnotations: {}

  # Optional additional annotations to add to the webhook ValidatingWebhookConfiguration
  # validatingWebhookConfigurationAnnotations: {}

  # Additional command line flags to pass to cert-manager webhook binary.
  # To see all available flags run docker run quay.io/jetstack/cert-manager-webhook:<version> --help
  extraArgs: []
  # Path to a file containing a WebhookConfiguration object used to configure the webhook
  # - --config=<path-to-config-file>

  resources: {}
    # requests:
    #   cpu: 10m
    #   memory: 32Mi

  ## Liveness and readiness probe values
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ##
  livenessProbe:
    failureThreshold: 3
    initialDelaySeconds: 60
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  readinessProbe:
    failureThreshold: 3
    initialDelaySeconds: 5
    periodSeconds: 5
    successThreshold: 1
    timeoutSeconds: 1

  nodeSelector:
    kubernetes.io/os: linux

  affinity: {}

  tolerations: []

  topologySpreadConstraints: []

  # Optional additional labels to add to the Webhook Pods
  podLabels: {}

  # Optional additional labels to add to the Webhook Service
  serviceLabels: {}

  image:
    repository: quay.io/jetstack/cert-manager-webhook
    # You can manage a registry with
    # registry: quay.io
    # repository: jetstack/cert-manager-webhook

    # Override the image tag to deploy by setting this variable.
    # If no value is set, the chart's appVersion will be used.
    # tag: canary

    # Setting a digest will override any tag
    # digest: sha256:0e072dddd1f7f8fc8909a2ca6f65e76c5f0d2fcfb8be47935ae3457e8bbceb20

    pullPolicy: IfNotPresent

  serviceAccount:
    # Specifies whether a service account should be created
    create: true
    # The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template
    # name: ""
    # Optional additional annotations to add to the controller's ServiceAccount
    # annotations: {}
    # Optional additional labels to add to the webhook's ServiceAccount
    # labels: {}
    # Automount API credentials for a Service Account.
    automountServiceAccountToken: true

  # Automounting API credentials for a particular pod
  # automountServiceAccountToken: true

  # The port that the webhook should listen on for requests.
  # In GKE private clusters, by default kubernetes apiservers are allowed to
  # talk to the cluster nodes only on 443 and 10250. so configuring
  # securePort: 10250, will work out of the box without needing to add firewall
  # rules or requiring NET_BIND_SERVICE capabilities to bind port numbers <1000
  securePort: 10250

  # Specifies if the webhook should be started in hostNetwork mode.
  #
  # Required for use in some managed kubernetes clusters (such as AWS EKS) with custom
  # CNI (such as calico), because control-plane managed by AWS cannot communicate
  # with pods' IP CIDR and admission webhooks are not working
  #
  # Since the default port for the webhook conflicts with kubelet on the host
  # network, `webhook.securePort` should be changed to an available port if
  # running in hostNetwork mode.
  hostNetwork: false

  # Specifies how the service should be handled. Useful if you want to expose the
  # webhook to outside of the cluster. In some cases, the control plane cannot
  # reach internal services.
  serviceType: ClusterIP
  # loadBalancerIP:

  # Overrides the mutating webhook and validating webhook so they reach the webhook
  # service using the `url` field instead of a service.
  url: {}
    # host:

  # Enables default network policies for webhooks.
  networkPolicy:
    enabled: false
    ingress:
    - from:
      - ipBlock:
          cidr: 0.0.0.0/0
    egress:
    - ports:
      - port: 80
        protocol: TCP
      - port: 443
        protocol: TCP
      - port: 53
        protocol: TCP
      - port: 53
        protocol: UDP
      # On OpenShift and OKD, the Kubernetes API server listens on
      # port 6443.
      - port: 6443
        protocol: TCP
      to:
      - ipBlock:
          cidr: 0.0.0.0/0

  volumes: []
  volumeMounts: []

cainjector:
  enabled: true
  replicaCount: ${local.actual_replica_count}

  strategy: {}
    # type: RollingUpdate
    # rollingUpdate:
    #   maxSurge: 0
    #   maxUnavailable: 1

  # Pod Security Context to be set on the cainjector component Pod
  # ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault

  podDisruptionBudget:
    enabled: false

    minAvailable: 1
    # maxUnavailable: 1

    # minAvailable and maxUnavailable can either be set to an integer (e.g. 1)
    # or a percentage value (e.g. 25%)

  # Container Security Context to be set on the cainjector component container
  # ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  containerSecurityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true


  # Optional additional annotations to add to the cainjector Deployment
  # deploymentAnnotations: {}

  # Optional additional annotations to add to the cainjector Pods
  # podAnnotations: {}

  # Additional command line flags to pass to cert-manager cainjector binary.
  # To see all available flags run docker run quay.io/jetstack/cert-manager-cainjector:<version> --help
  extraArgs: []
  # Enable profiling for cainjector
  # - --enable-profiling=true

  resources: {}
    # requests:
    #   cpu: 10m
    #   memory: 32Mi

  nodeSelector:
    kubernetes.io/os: linux

  affinity: {}

  tolerations: []

%{if var.ensure_high_availability~}
  topologySpreadConstraints:
  - labelSelector:
      matchLabels:
        app.kubernetes.io/name: "cainjector"
        app.kubernetes.io/instance: ${var.helm_release_name}
        app.kubernetes.io/component: "cainjector"
    topologyKey: topology.kubernetes.io/zone
    maxSkew: 1
    whenUnsatisfiable: ScheduleAnyway
  - labelSelector:
      matchLabels:
        app.kubernetes.io/name: "cainjector"
        app.kubernetes.io/instance: ${var.helm_release_name}
        app.kubernetes.io/component: "cainjector"
    topologyKey: kubernetes.io/hostname
    maxSkew: 1
    whenUnsatisfiable: ScheduleAnyway
%{else~}
  topologySpreadConstraints: []
%{endif~}

  # Optional additional labels to add to the CA Injector Pods
  podLabels: {}

  serviceAccount:
    # Specifies whether a service account should be created
    create: true
    # The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template
    # name: ""
    # Optional additional annotations to add to the controller's ServiceAccount
    # annotations: {}
    # Automount API credentials for a Service Account.
    # Optional additional labels to add to the cainjector's ServiceAccount
    # labels: {}
    automountServiceAccountToken: true

  # Automounting API credentials for a particular pod
  # automountServiceAccountToken: true

  volumes: []
  volumeMounts: []

#acmesolver:

# This startupapicheck is a Helm post-install hook that waits for the webhook
# endpoints to become available.
# The check is implemented using a Kubernetes Job- if you are injecting mesh
# sidecar proxies into cert-manager pods, you probably want to ensure that they
# are not injected into this Job's pod. Otherwise the installation may time out
# due to the Job never being completed because the sidecar proxy does not exit.
# See https://github.com/cert-manager/cert-manager/pull/4414 for context.
startupapicheck:
  enabled: true

  # Pod Security Context to be set on the startupapicheck component Pod
  # ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault

  # Container Security Context to be set on the controller component container
  # ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  containerSecurityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true

  # Timeout for 'kubectl check api' command
  timeout: 1m

  # Job backoffLimit
  backoffLimit: 4

  # Optional additional annotations to add to the startupapicheck Job
  jobAnnotations:
    helm.sh/hook: post-install
    helm.sh/hook-weight: "1"
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded

  # Optional additional annotations to add to the startupapicheck Pods
  # podAnnotations: {}

  # Additional command line flags to pass to startupapicheck binary.
  # To see all available flags run docker run quay.io/jetstack/cert-manager-ctl:<version> --help
  extraArgs: []

  resources: {}
    # requests:
    #   cpu: 10m
    #   memory: 32Mi

  nodeSelector:
    kubernetes.io/os: linux

  affinity: {}

  tolerations: []

  # Optional additional labels to add to the startupapicheck Pods
  podLabels: {}

  rbac:
    # annotations for the startup API Check job RBAC and PSP resources
    annotations:
      helm.sh/hook: post-install
      helm.sh/hook-weight: "-5"
      helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded

  # Automounting API credentials for a particular pod
  # automountServiceAccountToken: true

  serviceAccount:
    # Specifies whether a service account should be created
    create: true

    # The name of the service account to use.
    # If not set and create is true, a name is generated using the fullname template
    # name: ""

    # Optional additional annotations to add to the Job's ServiceAccount
    annotations:
      helm.sh/hook: post-install
      helm.sh/hook-weight: "-5"
      helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded

    # Automount API credentials for a Service Account.
    automountServiceAccountToken: true

    # Optional additional labels to add to the startupapicheck's ServiceAccount
    # labels: {}

  volumes: []
  volumeMounts: []
EOT
}

resource "helm_release" "cert_manager" {
  chart             = local.helm_chart_name
  repository        = "https://charts.jetstack.io"
  name              = var.helm_release_name
  version           = var.helm_chart_version
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  namespace         = var.kubernetes_namespace_owned ? kubernetes_namespace_v1.cert_manager[0].metadata[0].name : var.kubernetes_namespace_name
  create_namespace  = false
  values            = [local.cert_manager_values]
  depends_on        = [aws_iam_role_policy.cert_manager]
}