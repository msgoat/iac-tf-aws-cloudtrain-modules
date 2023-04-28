locals {
  kibana_values = <<EOT
elasticsearchHosts: "http://${module.elasticsearch.elasticsearch_service_name}:${module.elasticsearch.elasticsearch_service_port}"

replicas: 1

# Extra environment variables to append to this nodeGroup
# This will be appended to the current 'env:' key. You can use any of the kubernetes env
# syntax here
extraEnvs:
  - name: "NODE_OPTIONS"
    value: "--max-old-space-size=1800"
#  - name: MY_ENVIRONMENT_VAR
#    value: the_value_goes_here

# Allows you to load environment variables from kubernetes secret or config map
envFrom: []
# - secretRef:
#     name: env-secret
# - configMapRef:
#     name: config-map

# A list of secrets and their paths to mount inside the pod
# This is useful for mounting certificates for security and for mounting
# the X-Pack license
secretMounts: []
#  - name: kibana-keystore
#    secretName: kibana-keystore
#    path: /usr/share/kibana/data/kibana.keystore
#    subPath: kibana.keystore # optional

hostAliases: []
#- ip: "127.0.0.1"
#  hostnames:
#  - "foo.local"
#  - "bar.local"

podAnnotations: {}
# iam.amazonaws.com/role: es-cluster

resources:
  requests:
    cpu: "500m"
    memory: "1Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"

protocol: http

serverHost: "0.0.0.0"

healthCheckPath: "/app/kibana"

# Allows you to add any config files in /usr/share/kibana/config/
# such as kibana.yml
kibanaConfig: {}
#   kibana.yml: |
#     key:
#       nestedkey: value

# If Pod Security Policy in use it may be required to specify security context as well as service account

podSecurityContext:
  fsGroup: 1000

securityContext:
  capabilities:
    drop:
      - ALL
  # readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000

serviceAccount: ""

httpPort: 5601

updateStrategy:
  type: "Recreate"

service:
  type: ClusterIP
  port: 5601

ingress:
  enabled: true
  className: traefik
  annotations:
    traefik.ingress.kubernetes.io/router.pathmatcher: PathPrefix
  hosts:
    - host: ${var.kibana_host_name}
      paths:
        - path: ${var.kibana_path}

readinessProbe:
  failureThreshold: 3
  initialDelaySeconds: 10
  periodSeconds: 10
  successThreshold: 3
  timeoutSeconds: 5
EOT
}

resource helm_release kibana {
  chart = "kibana"
  version = "7.17.1"
  repository = "https://helm.elastic.co"
  name = "kibana"
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  namespace = var.kubernetes_namespace_name
  values = [ local.kibana_values ]
}