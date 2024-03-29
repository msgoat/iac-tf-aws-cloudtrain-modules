locals {
  actual_kibana_version = var.kibana_version != "" ? var.kibana_version : var.elasticsearch_version
  kibana_release_name = "${var.helm_release_name}-kibana"
  # render helm chart values since direct passing of values does not work in all cases
  kibana_values = <<EOT
fullnameOverride: "${local.kibana_release_name}"
version: ${local.actual_kibana_version}
labels: {}
annotations: {}
spec:
  count: 1
  elasticsearchRef:
    name: ${local.elasticsearch_release_name}
    # Optional namespace reference to Elasticsearch resource.
    # If not specified, then the namespace of the Kibana resource
    # will be assumed.
    #
    namespace: ${kubernetes_namespace.this[0].metadata[0].name}

  # Switch off TLS since TSL termination is done by Application Gateway
  http:
    tls:
      selfSignedCertificate:
        disabled: true

  # General Kibana configuration
  config:
    logging:
      appenders:
        console_appender:
          type: console
          layout:
            type: pattern
            highlight: false
      root:
        appenders: [console_appender]
        level: all
    server:
      basePath: "${var.kibana_path}"
      publicBaseUrl: "https://${var.kibana_host_name}${var.kibana_path}"

  # Configure pod
  podTemplate:
    spec:
      containers:
      - name: kibana
        env:
          - name: NODE_OPTIONS
            value: "--max-old-space-size=2048"
        resources:
          requests:
            memory: 1Gi
            cpu: 0.5
          limits:
            memory: 2.5Gi
            cpu: 2
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

# --- additional stuff not included in the upstream chart
ingress:
  enabled: true
  className: ${var.kubernetes_ingress_class_name}
%{ if var.kubernetes_ingress_controller_type == "NGINX" && var.kibana_path != "/" ~}
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
%{ endif ~}
  pathType: Prefix
  host: "${var.kibana_host_name}"
%{ if var.kubernetes_ingress_controller_type == "NGINX" && var.kibana_path != "/" ~}
  path: "${var.kibana_path}(/|$)(.*)"
%{ else ~}
  path: "${var.kibana_path}"
%{ endif ~}
EOT
}

resource helm_release kibana {
  chart = "${path.module}/resources/helm/eck-kibana"
  name = local.kibana_release_name
  dependency_update = true
  atomic = false
  cleanup_on_fail = false
  namespace = var.kubernetes_namespace_owned ? kubernetes_namespace.this[0].metadata[0].name : var.kubernetes_namespace_name
  values = [ local.kibana_values ]
  depends_on = [ helm_release.elasticsearch ]
}