locals {
  traefik_values = <<EOT
#
# Configure the deployment
#
deployment:
  enabled: true
  # Can be either Deployment or DaemonSet
  kind: Deployment
  # Number of pods of the deployment (only applies when kind == Deployment)
  replicas: 1
  # Amount of time (in seconds) before Kubernetes will send the SIGKILL signal if Traefik does not shut down
  terminationGracePeriodSeconds: 60
  # The minimum number of seconds Traefik needs to be up and running before the DaemonSet/Deployment controller considers it available
  minReadySeconds: 0
  # Additional deployment annotations (e.g. for jaeger-operator sidecar injection)
  annotations: {}
  # Additional deployment labels (e.g. for filtering deployment by custom labels)
  labels: {}
  # Additional pod annotations (e.g. for mesh injection or prometheus scraping)
  podAnnotations: {}
  # Additional Pod labels (e.g. for filtering Pod by custom labels)
  podLabels: {}
  # Additional containers (e.g. for metric offloading sidecars)
  additionalContainers: []
    # https://docs.datadoghq.com/developers/dogstatsd/unix_socket/?tab=host
    # - name: socat-proxy
    # image: alpine/socat:1.0.5
    # args: ["-s", "-u", "udp-recv:8125", "unix-sendto:/socket/socket"]
    # volumeMounts:
    #   - name: dsdsocket
    #     mountPath: /socket
  # Additional volumes available for use with initContainers and additionalContainers
  additionalVolumes: []
    # - name: dsdsocket
    #   hostPath:
    #     path: /var/run/statsd-exporter
  # Additional initContainers (e.g. for setting file permission as shown below)
  initContainers: []
    # The "volume-permissions" init container is required if you run into permission issues.
    # Related issue: https://github.com/traefik/traefik/issues/6972
    # - name: volume-permissions
    #   image: busybox:1.31.1
    #   command: ["sh", "-c", "chmod -Rv 600 /data/*"]
    #   volumeMounts:
    #     - name: data
    #       mountPath: /data
  # Use process namespace sharing
  shareProcessNamespace: false
  # Custom pod DNS policy. Apply if `hostNetwork: true`
  # dnsPolicy: ClusterFirstWithHostNet

# Pod disruption budget
podDisruptionBudget:
  enabled: true
  maxUnavailable: 1
  # maxUnavailable: 33%
  # minAvailable: 0
  # minAvailable: 25%

# Use ingressClass. Ignored if Traefik version < 2.3 / kubernetes < 1.18.x
ingressClass:
  # true is not unit-testable yet, pending https://github.com/rancher/helm-unittest/pull/12
  enabled: true
  isDefaultClass: ${var.default_ingress_class}
  # Use to force a networking.k8s.io API Version for certain CI/CD applications. E.g. "v1beta1"
  fallbackApiVersion: ""

# Create an IngressRoute for the dashboard
ingressRoute:
  dashboard:
    enabled: true

#
# Configure providers
#
providers:
  kubernetesCRD:
    enabled: true
    allowCrossNamespace: false
    allowExternalNameServices: false
    # ingressClass: traefik-internal
    # labelSelector: environment=production,method=traefik
    namespaces: []
      # - "default"

  kubernetesIngress:
    enabled: true
    allowExternalNameServices: false
    allowEmptyServices: false
    # ingressClass: traefik-internal
    # labelSelector: environment=production,method=traefik
    namespaces: []
      # - "default"
    # IP used for Kubernetes Ingress endpoints
    publishedService:
      enabled: false
      # Published Kubernetes Service to copy status from. Format: namespace/servicename
      # By default this Traefik service
      # pathOverride: ""

#
# Add volumes to the traefik pod. The volume name will be passed to tpl.
# This can be used to mount a cert pair or a configmap that holds a config.toml file.
# After the volume has been mounted, add the configs into traefik by using the `additionalArguments` list below, eg:
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

# Additional volumeMounts to add to the Traefik container
additionalVolumeMounts: []
  # For instance when using a logshipper for access logs
  # - name: traefik-logs
  #   mountPath: /var/log/traefik

# Logs
# https://docs.traefik.io/observability/logs/
logs:
  # Traefik logs concern everything that happens to Traefik itself (startup, configuration, events, shutdown, and so on).
  general:
    # By default, the logs use a text format (common), but you can
    # also ask for the json format in the format option
    format: json
    # By default, the level is set to ERROR. Alternative logging levels are DEBUG, PANIC, FATAL, ERROR, WARN, and INFO.
    level: INFO
  access:
    # To enable access logs
    enabled: false
    # By default, logs are written using the Common Log Format (CLF).
    # To write logs in JSON, use json in the format option.
    # If the given format is unsupported, the default (CLF) is used instead.
    # format: json
    # To write the logs in an asynchronous fashion, specify a bufferingSize option.
    # This option represents the number of log lines Traefik will keep in memory before writing
    # them to the selected output. In some cases, this option can greatly help performances.
    # bufferingSize: 100
    # Filtering https://docs.traefik.io/observability/access-logs/#filtering
    filters: {}
      # statuscodes: "200,300-302"
      # retryattempts: true
      # minduration: 10ms
    # Fields
    # https://docs.traefik.io/observability/access-logs/#limiting-the-fieldsincluding-headers
    fields:
      general:
        defaultmode: keep
        names: {}
          # Examples:
          # ClientUsername: drop
      headers:
        defaultmode: drop
        names: {}
          # Examples:
          # User-Agent: redact
          # Authorization: drop
          # Content-Type: keep

metrics:
  # datadog:
  #   address: 127.0.0.1:8125
  # influxdb:
  #   address: localhost:8089
  #   protocol: udp
  prometheus:
    entryPoint: metrics
  #  addRoutersLabels: true
  # statsd:
  #   address: localhost:8125

tracing: {}
  # instana:
  #   enabled: true
  # datadog:
  #   localAgentHostPort: 127.0.0.1:8126
  #   debug: false
  #   globalTag: ""
  #   prioritySampling: false

globalArguments:
  - "--global.checknewversion"
#  - "--global.sendanonymoususage"

#
# Configure Traefik static configuration
# Additional arguments to be passed at Traefik's binary
# All available options available on https://docs.traefik.io/reference/static-configuration/cli/
## Use curly braces to pass values: `helm install --set="additionalArguments={--providers.kubernetesingress.ingressclass=traefik-internal,--log.level=DEBUG}"`
additionalArguments: []
#  - "--providers.kubernetesingress.ingressclass=traefik-internal"
#  - "--log.level=DEBUG"

# Environment variables to be passed to Traefik's binary
env: []
# - name: SOME_VAR
#   value: some-var-value
# - name: SOME_VAR_FROM_CONFIG_MAP
#   valueFrom:
#     configMapRef:
#       name: configmap-name
#       key: config-key
# - name: SOME_SECRET
#   valueFrom:
#     secretKeyRef:
#       name: secret-name
#       key: secret-key

envFrom: []
# - configMapRef:
#     name: config-map-name
# - secretRef:
#     name: secret-name

# Configure ports
ports:
  # The name of this one can't be changed as it is used for the readiness and
  # liveness probes, but you can adjust its config to your liking
  traefik:
    port: 9000
    # Use hostPort if set.
    # hostPort: 9000
    #
    # Use hostIP if set. If not set, Kubernetes will default to 0.0.0.0, which
    # means it's listening on all your interfaces and all your IPs. You may want
    # to set this value if you need traefik to listen on specific interface
    # only.
    # hostIP: 192.168.100.10

    # Override the liveness/readiness port. This is useful to integrate traefik
    # with an external Load Balancer that performs healthchecks.
    # healthchecksPort: 9090

    # Defines whether the port is exposed if service.type is LoadBalancer or
    # NodePort.
    #
    # You SHOULD NOT expose the traefik port on production deployments.
    # If you want to access it from outside of your cluster,
    # use `kubectl port-forward` or create a secure ingress
    expose: true
    # The exposed port for this service
    exposedPort: 9000
    nodePort: 32090
    # The port protocol (TCP/UDP)
    protocol: TCP
  web:
    port: 8000
    # hostPort: 8000
    expose: true
    exposedPort: 80
    # The port protocol (TCP/UDP)
    protocol: TCP
    # Use nodeport if set. This is useful if you have configured Traefik in a
    # LoadBalancer
    nodePort: 32080
    # Port Redirections
    # Added in 2.2, you can make permanent redirects via entrypoints.
    # https://docs.traefik.io/routing/entrypoints/#redirection
    # redirectTo: websecure
  websecure:
    port: 8443
    # hostPort: 8443
    expose: false
    exposedPort: 443
    # The port protocol (TCP/UDP)
    protocol: TCP
    nodePort: 32443
    # Enable HTTP/3.
    # Requires enabling experimental http3 feature and tls.
    # Note that you cannot have a UDP entrypoint with the same port.
    # http3: true
    # Set TLS at the entrypoint
    # https://doc.traefik.io/traefik/routing/entrypoints/#tls
    tls:
      enabled: false
      # this is the name of a TLSOption definition
      options: ""
      certResolver: ""
      domains: []
      # - main: example.com
      #   sans:
      #     - foo.example.com
      #     - bar.example.com
  metrics:
    port: 9100
    # hostPort: 9100
    # Defines whether the port is exposed if service.type is LoadBalancer or
    # NodePort.
    #
    # You may not want to expose the metrics port on production deployments.
    # If you want to access it from outside of your cluster,
    # use `kubectl port-forward` or create a secure ingress
    expose: false
    # The exposed port for this service
    exposedPort: 9100
    # The port protocol (TCP/UDP)
    protocol: TCP

# TLS Options are created as TLSOption CRDs
# https://doc.traefik.io/traefik/https/tls/#tls-options
# Example:
# tlsOptions:
#   default:
#     sniStrict: true
#     preferServerCipherSuites: true
#   foobar:
#     curvePreferences:
#       - CurveP521
#       - CurveP384
tlsOptions: {}

# Options for the main traefik service, where the entrypoints traffic comes
# from.
service:
  enabled: true
  type: NodePort
  # Additional annotations applied to both TCP and UDP services (e.g. for cloud provider specific config)
  annotations: {}
  # Additional annotations for TCP service only
  annotationsTCP: {}
  # Additional annotations for UDP service only
  annotationsUDP: {}
  # Additional service labels (e.g. for filtering Service by custom labels)
  labels: {}
  # Additional entries here will be added to the service spec.
  # Cannot contain type, selector or ports entries.
  spec: {}
    # externalTrafficPolicy: Cluster
    # loadBalancerIP: "1.2.3.4"
    # clusterIP: "2.3.4.5"
  loadBalancerSourceRanges: []
    # - 192.168.0.1/32
    # - 172.16.0.0/16
  externalIPs: []
    # - 1.2.3.4
  # One of SingleStack, PreferDualStack, or RequireDualStack.
  # ipFamilyPolicy: SingleStack
  # List of IP families (e.g. IPv4 and/or IPv6).
  # ref: https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services
  # ipFamilies:
  #   - IPv4
  #   - IPv6

## Create HorizontalPodAutoscaler object.
##
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      targetAverageUtilization: 60
  - type: Resource
    resource:
      name: memory
      targetAverageUtilization: 60

# Enable persistence using Persistent Volume Claims
# ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
# After the pvc has been mounted, add the configs into traefik by using the `additionalArguments` list below, eg:
# additionalArguments:
# - "--certificatesresolvers.le.acme.storage=/data/acme.json"
# It will persist TLS certificates.
persistence:
  enabled: false
  name: data
#  existingClaim: ""
  accessMode: ReadWriteOnce
  size: 128Mi
  # storageClass: ""
  path: /data
  annotations: {}
  # subPath: "" # only mount a subpath of the Volume into the pod

# If hostNetwork is true, runs traefik in the host network namespace
# To prevent unschedulabel pods due to port collisions, if hostNetwork=true
# and replicas>1, a pod anti-affinity is recommended and will be set if the
# affinity is left as default.
hostNetwork: false

# Whether Role Based Access Control objects like roles and rolebindings should be created
rbac:
  enabled: true

  # If set to false, installs ClusterRole and ClusterRoleBinding so Traefik can be used across namespaces.
  # If set to true, installs namespace-specific Role and RoleBinding and requires provider configuration be set to that same namespace
  namespaced: false

# Enable to create a PodSecurityPolicy and assign it to the Service Account via RoleBinding or ClusterRoleBinding
podSecurityPolicy:
  enabled: false

# The service account the pods will use to interact with the Kubernetes API
serviceAccount:
  # If set, an existing service account is used
  # If not set, a service account is created automatically using the fullname template
  name: ""

# Additional serviceAccount annotations (e.g. for oidc authentication)
serviceAccountAnnotations: {}

resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "300m"
    memory: "150Mi"
affinity:
# # This example pod anti-affinity forces the scheduler to put traefik pods
# # on nodes where no other traefik pods are scheduled.
# # It should be used when hostNetwork: true to prevent port conflicts
#  podAntiAffinity:
#    requiredDuringSchedulingIgnoredDuringExecution:
#      - labelSelector:
#          matchExpressions:
#            - key: app.kubernetes.io/name
#              operator: In
#              values:
#                - {{ template "traefik.name" . }}
#        topologyKey: kubernetes.io/hostname

# Set the container security context
# To run the container with ports below 1024 this will need to be adjust to run as root
securityContext:
  capabilities:
    drop: [ALL]
  readOnlyRootFilesystem: true
  runAsGroup: 65532
  runAsNonRoot: true
  runAsUser: 65532

podSecurityContext:
  fsGroup: 65532
EOT
}

resource helm_release traefik {
  chart = "traefik"
  version = "10.19.4"
  name = var.helm_release_name
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  create_namespace = true
  namespace = var.kubernetes_namespace_name
  repository = "https://helm.traefik.io/traefik"
  values = [ local.traefik_values ]
}