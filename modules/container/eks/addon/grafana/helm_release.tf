locals {
  helm_values = <<EOT
grafana:
  namespaceOverride: ""
  forceDeployDatasources: false
  forceDeployDashboards: false
  defaultDashboardsEnabled: true
  defaultDashboardsTimezone: utc
  admin:
    existingSecret: ${kubernetes_secret.grafana_admin.metadata[0].name}
    userKey: grafana-admin-user
    passwordKey: grafana-admin-password
  rbac:
    pspEnabled: false
  ingress:
    enabled: true
    ingressClassName: ${var.kubernetes_ingress_class_name}
%{ if var.kubernetes_ingress_controller_type == "NGINX" && var.grafana_path != "" && var.grafana_path != "/" ~}
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /$2
%{ else ~}
    annotations: {}
%{ endif ~}
    labels: {}
    hosts: [ ${var.grafana_host_name} ]
%{ if var.kubernetes_ingress_controller_type == "NGINX" && var.grafana_path != "" && var.grafana_path != "/" ~}
    path: ${var.grafana_path}(/|$)(.*)
%{ else ~}
    path: ${var.grafana_path}
%{ endif ~}
    pathType: Prefix
    tls: []
  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard
      labelValue: "1"
      searchNamespace: ALL
      annotations: {}
      multicluster:
        global:
          enabled: false
        etcd:
          enabled: false
      provider:
        allowUiUpdates: false
    datasources:
      enabled: true
      defaultDatasourceEnabled: true
      isDefaultDatasource: true
      uid: prometheus
      # url: http://prometheus-stack-prometheus:9090/
      # timeout: 30
      # defaultDatasourceScrapeInterval: 15s
      annotations: {}
      httpMethod: POST
      createPrometheusReplicasDatasources: false
      label: grafana_datasource
      labelValue: "1"
      exemplarTraceIdDestinations: {}
        # datasourceUid: Jaeger
      # traceIdLabelName: trace_id
  extraConfigmapMounts: []
  deleteDatasources: []
  additionalDataSources: []
  # - name: prometheus-sample
  #   access: proxy
  #   basicAuth: true
  #   basicAuthPassword: pass
  #   basicAuthUser: daco
  #   editable: false
  #   jsonData:
  #       tlsSkipVerify: true
  #   orgId: 1
  #   type: prometheus
  #   url: https://{{ printf "%s-prometheus.svc" .Release.Name }}:9090
  #   version: 1
  service:
    portName: http-web
  serviceMonitor:
    enabled: true
    path: "/metrics"
    labels: {}
    interval: ""
    scheme: http
    tlsConfig: {}
    scrapeTimeout: 30s
    relabelings: []
  # Additional persistence settings to retain loaded dashboards
  persistence:
    enabled: true
    type: statefulset
    storageClassName: ${var.kubernetes_storage_class_name}
    size: 10Gi
  # Additional Grafana configuration to allow proper serving with paths
  grafana.ini:
    analytics:
      check_for_updates: false
    grafana_net:
      url: https://grafana.net
    log:
      mode: console
      level: info
      console:
        format: json
    paths:
      data: /var/lib/grafana/
      logs: /var/log/grafana
      plugins: /var/lib/grafana/plugins
      provisioning: /etc/grafana/provisioning
    server:
      domain: ${var.grafana_host_name}
      root_url: "https://${var.grafana_host_name}${var.grafana_path}"
      enforce_domain: true
      enable_gzip: true
EOT
}

resource helm_release grafana {
  chart = "grafana"
  version = var.helm_chart_version
  name = var.helm_release_name
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  create_namespace = true
  namespace = var.kubernetes_namespace_name
  repository = "https://grafana.github.io/helm-charts"
  values = [ local.prometheus_stack_values ]
  depends_on = [ kubernetes_namespace_v1.monitoring, kubernetes_secret.grafana_admin ]
}