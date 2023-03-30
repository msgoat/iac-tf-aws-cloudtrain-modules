locals {
  controller_replicas = var.replica_count
  controller_pdb_enabled = local.controller_replicas > 1 ? true : false
  controller_values = <<EOT
# Default values for aws-load-balancer-controller.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: ${local.controller_replicas}

nameOverride: ""
fullnameOverride: ""

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations:
    eks.amazonaws.com/role-arn: "${aws_iam_role.controller.arn}"
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name:
  # Automount API credentials for a Service Account.
  automountServiceAccountToken: true

rbac:
  # Specifies whether rbac resources should be created
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

# Time period for the controller pod to do a graceful shutdown
terminationGracePeriodSeconds: 10

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

# priorityClassName specifies the PriorityClass to indicate the importance of controller pods
# ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass
priorityClassName: system-cluster-critical

nodeSelector: {}

tolerations: []

# affinity specifies a custom affinity for the controller pods
affinity: {}

# configureDefaultAffinity specifies whether to configure a default affinity for the controller pods to prevent
# co-location on the same node. This will get ignored if you specify a custom affinity configuration.
configureDefaultAffinity: true

# topologySpreadConstraints is a stable feature of k8s v1.19 which provides the ability to
# control how Pods are spread across your cluster among failure-domains such as regions, zones,
# nodes, and other user-defined topology domains.
#
# more details here: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
topologySpreadConstraints: {}

updateStrategy: {}
  # type: RollingUpdate
  # rollingUpdate:
  #   maxSurge: 1
  #   maxUnavailable: 1

# serviceAnnotations contains annotations to be added to the provisioned webhook service resource
serviceAnnotations: {}

# deploymentAnnotations contains annotations for the controller deployment
deploymentAnnotations: {}

podAnnotations: {}

podLabels: {}

# additionalLabels -- Labels to add to each object of the chart.
additionalLabels: {}

# Enable cert-manager
enableCertManager: false

# The name of the Kubernetes cluster. A non-empty value is required
clusterName: ${var.eks_cluster_name}

# cluster contains configurations specific to the kubernetes cluster
cluster:
    # Cluster DNS domain (required for requesting TLS certificates)
    dnsDomain: cluster.local

# The ingress class this controller will satisfy. If not specified, controller will match all
# ingresses without ingress class annotation and ingresses of type alb
ingressClass: alb

# ingressClassParams specify the IngressCLassParams that enforce settings for a set of Ingresses when using with ingress Controller.
ingressClassParams:
  create: true
  # The name of ingressClassParams resource will be referred in ingressClass
  name:
  spec: {}
    # You always can set specifications in `helm install` command through `--set` or `--set-string`
    # If you do want to specify specifications in values.yaml, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'spec:'.
    # namespaceSelector:
    #   matchLabels:
    # group:
    # scheme:
    # subnets:
    # ipAddressType:
    # tags:
    # loadBalancerAttributes:
    # - key:
    #   value:

# To use IngressClass resource instead of annotation, before you need to install the IngressClass resource pointing to controller.
# If specified as true, the IngressClass resource will be created.
createIngressClassResource: true

# The AWS region for the kubernetes cluster. Set to use KIAM or kube2iam for example.
region: ${var.region_name}

# The VPC ID for the Kubernetes cluster. Set this manually when your pods are unable to use the metadata service to determine this automatically
vpcId:

# Custom AWS API Endpoints (serviceID1=URL1,serviceID2=URL2)
awsApiEndpoints:

# awsApiThrottle specifies custom AWS API throttle settings (serviceID1:operationRegex1=rate:burst,serviceID2:operationRegex2=rate:burst)
# example: --set awsApiThrottle="{Elastic Load Balancing v2:RegisterTargets|DeregisterTargets=4:20,Elastic Load Balancing v2:.*=10:40}"
awsApiThrottle:

# Maximum retries for AWS APIs (default 10)
awsMaxRetries:

# Default target type. Used as the default value of the "alb.ingress.kubernetes.io/target-type" and
# "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" annotations.
# Possible values are "ip" and "instance"
# The value "ip" should be used for ENI-based CNIs, such as the Amazon VPC CNI,
# Calico with encapsulation disabled, or Cilium with masquerading disabled.
# The value "instance" should be used for overlay-based CNIs, such as Calico in VXLAN or IPIP mode or
# Cilium with masquerading enabled.
defaultTargetType: ip

# If enabled, targetHealth readiness gate will get injected to the pod spec for the matching endpoint pods (default true)
enablePodReadinessGateInject:

# Enable Shield addon for ALB (default true)
enableShield:

# Enable WAF addon for ALB (default true)
enableWaf:

# Enable WAF V2 addon for ALB (default true)
enableWafv2:

# Maximum number of concurrently running reconcile loops for ingress (default 3)
ingressMaxConcurrentReconciles:

# Set the controller log level - info(default), debug (default "info")
logLevel:

# The address the metric endpoint binds to. (default ":8080")
metricsBindAddr: ""

# The TCP port the Webhook server binds to. (default 9443)
webhookBindPort:

# webhookTLS specifies TLS cert/key for the webhook
webhookTLS:
  caCert:
  cert:
  key:

# array of namespace selectors for the webhook
webhookNamespaceSelectors:
# - key: elbv2.k8s.aws/pod-readiness-gate-inject
#   operator: In
#   values:
#   - enabled

# keepTLSSecret specifies whether to reuse existing TLS secret for chart upgrade
keepTLSSecret: true

# Maximum number of concurrently running reconcile loops for service (default 3)
serviceMaxConcurrentReconciles:

# Maximum number of concurrently running reconcile loops for targetGroupBinding
targetgroupbindingMaxConcurrentReconciles:

# Maximum duration of exponential backoff for targetGroupBinding reconcile failures
targetgroupbindingMaxExponentialBackoffDelay:

# Period at which the controller forces the repopulation of its local object stores. (default 1h0m0s)
syncPeriod:

# Namespace the controller watches for updates to Kubernetes objects, If empty, all namespaces are watched.
watchNamespace:

# disableIngressClassAnnotation disables the usage of kubernetes.io/ingress.class annotation, false by default
disableIngressClassAnnotation:

# disableIngressGroupNameAnnotation disables the usage of alb.ingress.kubernetes.io/group.name annotation, false by default
disableIngressGroupNameAnnotation:

# defaultSSLPolicy specifies the default SSL policy to use for TLS/HTTPS listeners
defaultSSLPolicy:

# Liveness probe configuration for the controller
livenessProbe:
  failureThreshold: 2
  httpGet:
    path: /healthz
    port: 61779
    scheme: HTTP
  initialDelaySeconds: 30
  timeoutSeconds: 10

# Environment variables to set for aws-load-balancer-controller pod.
# We strongly discourage programming access credentials in the controller environment. You should setup IRSA or
# comparable solutions like kube2iam, kiam etc instead.
env:
  # ENV_1: ""
  # ENV_2: ""

# Specifies if aws-load-balancer-controller should be started in hostNetwork mode.
#
# This is required if using a custom CNI where the managed control plane nodes are unable to initiate
# network connections to the pods, for example using Calico CNI plugin on EKS. This is not required or
# recommended if using the Amazon VPC CNI plugin.
hostNetwork: false

# Specifies the dnsPolicy that should be used for pods in the deployment
#
# This may need to be used to be changed given certain conditions. For instance, if one uses the cilium CNI
# with certain settings, one may need to set `hostNetwork: true` and webhooks won't work unless `dnsPolicy`
# is set to `ClusterFirstWithHostNet`. See https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy
dnsPolicy:

# extraVolumeMounts are the additional volume mounts. This enables setting up IRSA on non-EKS Kubernetes cluster
extraVolumeMounts:
  # - name: aws-iam-token
  #   mountPath: /var/run/secrets/eks.amazonaws.com/serviceaccount
  #   readOnly: true

# extraVolumes for the extraVolumeMounts. Useful to mount a projected service account token for example.
extraVolumes:
  # - name: aws-iam-token
  #   projected:
  #     defaultMode: 420
  #     sources:
  #     - serviceAccountToken:
  #         audience: sts.amazonaws.com
  #         expirationSeconds: 86400
  #         path: token

# defaultTags are the tags to apply to all AWS resources managed by this controller
defaultTags: {}
  # default_tag1: value1
  # default_tag2: value2

%{ if local.controller_pdb_enabled ~}
podDisruptionBudget:
  maxUnavailable: 1
%{ endif ~}

# externalManagedTags is the list of tag keys on AWS resources that will be managed externally
externalManagedTags: []

# enableEndpointSlices enables k8s EndpointSlices for IP targets instead of Endpoints (default false)
enableEndpointSlices:

# enableBackendSecurityGroup enables shared security group for backend traffic (default true)
enableBackendSecurityGroup:

# backendSecurityGroup specifies backend security group id (default controller auto create backend security group)
backendSecurityGroup:

# disableRestrictedSecurityGroupRules specifies whether to disable creating port-range restricted security group rules for traffic
disableRestrictedSecurityGroupRules:

# controllerConfig specifies controller configuration
controllerConfig:
  # featureGates set of key: value pairs that describe AWS load balance controller features
  featureGates: {}
  #  ServiceTypeLoadBalancerOnly: true
  #  EndpointsFailOpen: true

# objectSelector for webhook
objectSelector:
  matchExpressions:
  # - key: <key>
  #   operator: <operator>
  #   values:
  #   - <value>
  matchLabels:
  #   key: value

serviceMonitor:
  # Specifies whether a service monitor should be created
  enabled: false
  # Labels to add to the service account
  additionalLabels: {}
  # Prometheus scrape interval
  interval: 1m
  # Namespace to create the service monitor in
  namespace:

# clusterSecretsPermissions lets you configure RBAC permissions for secret resources
# Access to secrets resource is required only if you use the OIDC feature, and instead of
# enabling access to all secrets, we recommend configuring namespaced role/rolebinding.
# This option is for backwards compatibility only, and will potentially be deprecated in future.
clusterSecretsPermissions:
  # allowAllSecrets allows the controller to access all secrets in the cluster.
  # This is to get backwards compatible behavior, but *NOT* recommended for security reasons
  allowAllSecrets: false

# ingressClassConfig contains configurations specific to the ingress class
ingressClassConfig:
  default: false
EOT
}

resource "helm_release" "controller" {
  chart             = "aws-load-balancer-controller"
  repository        = "https://aws.github.io/eks-charts"
  name              = var.helm_release_name
  version           = var.helm_chart_version
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  namespace         = var.kubernetes_namespace_name
  create_namespace  = true
  values            = [ local.controller_values ]
  depends_on        = [ aws_iam_role_policy.controller ]
}