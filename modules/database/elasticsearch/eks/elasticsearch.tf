locals {
  elasticsearch_values = <<EOT
clusterName: ${var.elasticsearch_cluster_name}
nodeGroup: "master"

# The service that non master groups will try to connect to when joining the cluster
# This should be set to clusterName + "-" + nodeGroup for your master group
masterService: ""

# Elasticsearch roles that will be applied to this nodeGroup
# These will be set as environment variables. E.g. node.master=true
roles:
  master: "true"
  ingest: "true"
  data: "true"
  remote_cluster_client: "false"
  ml: "true"
  transform: "true"

replicas: 3
minimumMasterNodes: 2

esMajorVersion: ""

# Allows you to add any config files in /usr/share/elasticsearch/config/
# such as elasticsearch.yml and log4j2.properties
esConfig: {}
#  elasticsearch.yml: |
#    key:
#      nestedkey: value
#  log4j2.properties: |
#    key = value

# Extra environment variables to append to this nodeGroup
# This will be appended to the current 'env:' key. You can use any of the eks env
# syntax here
extraEnvs: []
#  - name: MY_ENVIRONMENT_VAR
#    value: the_value_goes_here

# Allows you to load environment variables from eks secret or config map
envFrom: []
# - secretRef:
#     name: env-secret
# - configMapRef:
#     name: config-map

# A list of secrets and their paths to mount inside the pod
# This is useful for mounting certificates for security and for mounting
# the X-Pack license
secretMounts: []
#  - name: elastic-certificates
#    secretName: elastic-certificates
#    path: /usr/share/elasticsearch/config/certs
#    defaultMode: 0755

hostAliases: []
#- ip: "127.0.0.1"
#  hostnames:
#  - "foo.local"
#  - "bar.local"

podAnnotations: {}
# iam.amazonaws.com/role: es-cluster

# additionals labels
labels: {}

esJavaOpts: "-Xmx1g -Xms1g"

resources:
  requests:
    cpu: "500m"
    memory: "2Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"

initResources: {}
  # limits:
  #   cpu: "25m"
  #   # memory: "128Mi"
  # requests:
  #   cpu: "25m"
#   memory: "128Mi"

sidecarResources: {}
  # limits:
  #   cpu: "25m"
  #   # memory: "128Mi"
  # requests:
  #   cpu: "25m"
#   memory: "128Mi"

networkHost: "0.0.0.0"

volumeClaimTemplate:
  storageClassName: gp2
  accessModes: [ "ReadWriteOnce" ]
  resources:
    requests:
      storage: ${var.elasticsearch_storage_size}Gi

rbac:
  create: true
  serviceAccountAnnotations: {}
  serviceAccountName: ""

podSecurityPolicy:
  create: false
  name: ""
  spec:
    privileged: true
    fsGroup:
      rule: RunAsAny
    runAsUser:
      rule: RunAsAny
    seLinux:
      rule: RunAsAny
    supplementalGroups:
      rule: RunAsAny
    volumes:
      - secret
      - configMap
      - persistentVolumeClaim
      - emptyDir

persistence:
  enabled: true
  labels:
    # Add default labels for the volumeClaimTemplate of the StatefulSet
    enabled: false
  annotations: {}

extraVolumes: []
  # - name: extras
#   emptyDir: {}

extraVolumeMounts: []
  # - name: extras
  #   mountPath: /usr/share/extras
#   readOnly: true

extraContainers: []
  # - name: do-something
  #   image: busybox
#   command: ['do', 'something']

extraInitContainers: []
  # - name: do-something
  #   image: busybox
#   command: ['do', 'something']

# This is the PriorityClass settings as defined in
# https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass
priorityClassName: ""

# By default this will make sure two pods don't end up on the same node
# Changing this to a region would allow you to spread pods across regions
antiAffinityTopologyKey: "failure-domain.beta.eks.io/zone"

# Hard means that by default pods will only be scheduled if there are enough nodes for them
# and that they will never end up on the same node. Setting this to soft will do this "best effort"
antiAffinity: "soft"

# This is the node affinity settings as defined in
# https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#node-affinity-beta-feature
nodeAffinity: {}

# The default is to deploy all pods serially. By setting this to parallel all pods are started at
# the same time when bootstrapping the cluster
podManagementPolicy: "Parallel"

# The environment variables injected by service links are not used, but can lead to slow Elasticsearch boot times when
# there are many services in the current namespace.
# If you experience slow pod startups you probably want to set this to `false`.
enableServiceLinks: true

protocol: http
httpPort: 9200
transportPort: 9300

service:
  labels: {}
  labelsHeadless: {}
  type: ClusterIP
  nodePort: ""
  annotations: {}
  httpPortName: http
  transportPortName: transport
  loadBalancerIP: ""
  loadBalancerSourceRanges: []
  externalTrafficPolicy: ""

updateStrategy: RollingUpdate

# This is the max unavailable setting for the pod disruption budget
# The default value of 1 will make sure that eks won't allow more than 1
# of your pods to be unavailable during maintenance
maxUnavailable: 1

podSecurityContext:
  fsGroup: 1000
  runAsUser: 1000

securityContext:
  capabilities:
    drop:
      - ALL
  # readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000

# How long to wait for elasticsearch to stop gracefully
terminationGracePeriod: 120

sysctlVmMaxMapCount: 262144

readinessProbe:
  failureThreshold: 3
  initialDelaySeconds: 10
  periodSeconds: 10
  successThreshold: 3
  timeoutSeconds: 5

# https://www.elastic.co/guide/en/elasticsearch/reference/7.12/cluster-health.html#request-params wait_for_status
clusterHealthCheckParams: "wait_for_status=green&timeout=1s"

## Use an alternate scheduler.
## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
##
schedulerName: ""

imagePullSecrets: []
nodeSelector: {}
tolerations: []

# https://github.com/elastic/helm-charts/issues/63
masterTerminationFix: false

sysctlInitContainer:
  enabled: true

keystore: []

networkPolicy:
  ## Enable creation of NetworkPolicy resources. Only Ingress traffic is filtered for now.
  ## In order for a Pod to access Elasticsearch, it needs to have the following label:
  ## {{ template "uname" . }}-client: "true"
  ## Example for default configuration to access HTTP port:
  ## elasticsearch-master-http-client: "true"
  ## Example for default configuration to access transport port:
  ## elasticsearch-master-transport-client: "true"

  http:
    enabled: false
    ## if explicitNamespacesSelector is not set or set to {}, only client Pods being in the networkPolicy's namespace
    ## and matching all criteria can reach the DB.
    ## But sometimes, we want the Pods to be accessible to clients from other namespaces, in this case, we can use this
    ## parameter to select these namespaces
    ##
    # explicitNamespacesSelector:
    #   # Accept from namespaces with all those different rules (only from whitelisted Pods)
    #   matchLabels:
    #     role: frontend
    #   matchExpressions:
    #     - {key: role, operator: In, values: [frontend]}

    ## Additional NetworkPolicy Ingress "from" rules to set. Note that all rules are OR-ed.
    ##
    # additionalRules:
    #   - podSelector:
    #       matchLabels:
    #         role: frontend
    #   - podSelector:
    #       matchExpressions:
    #         - key: role
    #           operator: In
    #           values:
    #             - frontend

  transport:
    ## Note that all Elasticsearch Pods can talks to themselves using transport port even if enabled.
    enabled: false
    # explicitNamespacesSelector:
    #   matchLabels:
    #     role: frontend
    #   matchExpressions:
    #     - {key: role, operator: In, values: [frontend]}
    # additionalRules:
    #   - podSelector:
    #       matchLabels:
    #         role: frontend
    #   - podSelector:
    #       matchExpressions:
    #         - key: role
    #           operator: In
    #           values:
    #             - frontend
EOT
}

resource helm_release elasticsearch {
  chart = "elasticsearch"
  version = "7.17"
  repository = "https://helm.elastic.co"
  name = var.helm_release_name
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  create_namespace = true
  namespace = var.kubernetes_namespace_name
  values = [ local.elasticsearch_values ]
}