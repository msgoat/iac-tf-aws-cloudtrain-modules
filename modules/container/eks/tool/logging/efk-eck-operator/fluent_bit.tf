locals {
  fluent_bit_release_name = "${var.helm_release_name}-fluent-bit"
  es_certificates_mount_path = "/var/elasticsearch/certs"
  # render helm chart values since direct passing of values does not work in all cases
  fluent_bit_values = <<EOT
# Default values for fluent-bit.

# kind -- DaemonSet or Deployment
kind: DaemonSet

nameOverride: ""
fullnameOverride: "${local.fluent_bit_release_name}"

serviceAccount:
  create: true
  annotations: {}
  name:

rbac:
  create: true
  nodeAccess: false
  eventsAccess: false

podSecurityPolicy:
  create: false
  annotations: {}

podSecurityContext: {}
#  fsGroup: 2000

securityContext: {}
#  capabilities:
#    drop:
#    - ALL
#  readOnlyRootFilesystem: false
#  runAsNonRoot: true
#  runAsUser: 1000

env:
  - name: ELASTICSEARCH_USERNAME
    value: "elastic"
  - name: ELASTICSEARCH_PASSWORD
    valueFrom:
      secretKeyRef:
        name: ${local.elasticsearch_credentials_k8s_secret_name}
        key: elastic

service:
  type: ClusterIP
  port: 2020

serviceMonitor:
  enabled: ${var.prometheus_operator_enabled}

prometheusRule:
  enabled: false

dashboards:
  enabled: false

resources:
  limits:
    memory: 500Mi
  requests:
    cpu: 200m
    memory: 100Mi

%{ if var.node_group_workload_class != "" ~}
# It's OK to be deployed to the tools pool, too
tolerations:
  - key: "group.msg.cloud.kubernetes/workload"
    operator: "Equal"
    value: ${var.node_group_workload_class}
    effect: "NoSchedule"
%{ endif ~}

affinity: {}

podAnnotations: {}

podLabels: {}

networkPolicy:
  enabled: false

## https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/configuration-file
config:
  service: |
    [SERVICE]
        Daemon Off
        Flush {{ .Values.flush }}
        Log_Level {{ .Values.logLevel }}
        Parsers_File /fluent-bit/etc/parsers.conf
        Parsers_File /fluent-bit/etc/conf/custom_parsers.conf
        HTTP_Server On
        HTTP_Listen 0.0.0.0
        HTTP_Port {{ .Values.metricsPort }}
        Health_Check On

  ## https://docs.fluentbit.io/manual/pipeline/inputs
  inputs: |
    [INPUT]
        Name                tail
        Tag                 kube.*
        Path                /var/log/containers/*.log
        Exclude_Path        /var/log/containers/cloudwatch-agent*, /var/log/containers/fluent-bit*, /var/log/containers/aws-node*, /var/log/containers/kube-proxy*
        multiline.parser    docker, cri
        Mem_Buf_Limit       64MB
        Refresh_Interval    10
        Rotate_Wait         30
        Read_from_Head      True
        Skip_Long_Lines     On
        Skip_Empty_Lines    On
        DB                  /var/fluent-bit/state/tail-containers-state.db
        DB.Sync             Normal

  ## https://docs.fluentbit.io/manual/pipeline/filters
  filters: |
    [FILTER]
        Name kubernetes
        Match kube.*
        Merge_Log On
        Keep_Log Off
        K8S-Logging.Parser On
        K8S-Logging.Exclude On
        Labels On
        Annotations Off

    # Lift nested kubernetes metadata to root without changing the field names
    # Retag everything coming from internal kubernetes namespaces with k8s
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(kube) k8s false
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(azure) k8s false
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(gatekeeper) k8s false

    # Retag everything coming from system tool stack namespaces with sys
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(ingress) sys false
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(monitoring) sys false
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(logging) sys false
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(tracing) sys false
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(postgres) sys false
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(iam) sys false

    # Retag everything coming from tool chain namespaces with tools
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(tool) tools false

    # Retag everything coming from application namespaces with apps
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(cxp) apps false

    # Retag everything coming from application namespaces with apps
    [FILTER]
        Name         rewrite_tag
        Match        kube.*
        Rule         $kubernetes['namespace_name'] ^(cloudtrain) apps false

  ## https://docs.fluentbit.io/manual/pipeline/outputs
  outputs: |
    # send all k8s tags to k8s index
    [OUTPUT]
        Name               es
        Match              k8s
        Host               ${local.elasticsearch_service_name}
        Port               ${local.elasticsearch_service_port}
        Type               _doc
        Logstash_Format    On
        Logstash_Prefix    k8s-${var.eks_cluster_name}
        Time_Key           @flb-timestamp
        Generate_ID        On
        Replace_Dots       On
        Retry_Limit        3
        Suppress_Type_Name On
        HTTP_User          $${ELASTICSEARCH_USERNAME}
        HTTP_Passwd        $${ELASTICSEARCH_PASSWORD}
%{ if local.elasticsearch_tls_enabled ~}
        tls                On
        tls.ca_file        ${local.es_certificates_mount_path}/ca.crt
        tls.crt_file       ${local.es_certificates_mount_path}/tls.crt
%{ endif ~}

    # send all sys tags to sys index
    [OUTPUT]
        Name               es
        Match              sys
        Host               ${local.elasticsearch_service_name}
        Port               ${local.elasticsearch_service_port}
        Type               _doc
        Logstash_Format    On
        Logstash_Prefix    sys-${var.eks_cluster_name}
        Time_Key           @flb-timestamp
        Generate_ID        On
        Replace_Dots       On
        Retry_Limit        3
        Suppress_Type_Name On
        HTTP_User          $${ELASTICSEARCH_USERNAME}
        HTTP_Passwd        $${ELASTICSEARCH_PASSWORD}
%{ if local.elasticsearch_tls_enabled ~}
        tls                On
        tls.ca_file        ${local.es_certificates_mount_path}/ca.crt
        tls.crt_file       ${local.es_certificates_mount_path}/tls.crt
%{ endif ~}

    # send all tools tags to tools index
    [OUTPUT]
        Name               es
        Match              tools
        Host               ${local.elasticsearch_service_name}
        Port               ${local.elasticsearch_service_port}
        Type               _doc
        Logstash_Format    On
        Logstash_Prefix    tools-${var.eks_cluster_name}
        Time_Key           @flb-timestamp
        Generate_ID        On
        Replace_Dots       On
        Retry_Limit        3
        Suppress_Type_Name On
        HTTP_User          $${ELASTICSEARCH_USERNAME}
        HTTP_Passwd        $${ELASTICSEARCH_PASSWORD}
%{ if local.elasticsearch_tls_enabled ~}
        tls                On
        tls.ca_file        ${local.es_certificates_mount_path}/ca.crt
        tls.crt_file       ${local.es_certificates_mount_path}/tls.crt
%{ endif ~}

    # send all apps tags to apps index
    [OUTPUT]
        Name               es
        Match              apps
        Host               ${local.elasticsearch_service_name}
        Port               ${local.elasticsearch_service_port}
        Type               _doc
        Logstash_Format    On
        Logstash_Prefix    apps-${var.eks_cluster_name}
        Time_Key           @flb-timestamp
        Generate_ID        On
        Replace_Dots       On
        Retry_Limit        3
        Suppress_Type_Name On
        HTTP_User          $${ELASTICSEARCH_USERNAME}
        HTTP_Passwd        $${ELASTICSEARCH_PASSWORD}
%{ if local.elasticsearch_tls_enabled ~}
        tls                On
        tls.ca_file        ${local.es_certificates_mount_path}/ca.crt
        tls.crt_file       ${local.es_certificates_mount_path}/tls.crt
%{ endif ~}

  ## https://docs.fluentbit.io/manual/pipeline/parsers
  customParsers: |
    [PARSER]
        Name docker_no_time
        Format json
        Time_Keep Off
        Time_Key time
        Time_Format %Y-%m-%dT%H:%M:%S.%L

# The config volume is mounted by default, either to the existingConfigMap value, or the default of "fluent-bit.fullname"
volumeMounts:
  - name: config
    mountPath: /fluent-bit/etc/fluent-bit.conf
    subPath: fluent-bit.conf
  - name: config
    mountPath: /fluent-bit/etc/custom_parsers.conf
    subPath: custom_parsers.conf

daemonSetVolumes:
  - name: fluentbitstate
    hostPath:
      path: /var/fluent-bit/state
  - name: varlog
    hostPath:
      path: /var/log
  - name: varlibdockercontainers
    hostPath:
      path: /var/lib/docker/containers
  - name: etcmachineid
    hostPath:
      path: /etc/machine-id
      type: File
%{ if local.elasticsearch_tls_enabled ~}
  - name: elasticsearch-certs
    secret:
      secretName: ${local.elasticsearch_certificates_k8s_secret_name}
      optional: false
%{ endif ~}

daemonSetVolumeMounts:
  - name: fluentbitstate
    mountPath: /var/fluent-bit/state
  - name: varlog
    mountPath: /var/log
    readOnly: true
  - name: varlibdockercontainers
    mountPath: /var/lib/docker/containers
    readOnly: true
  - name: etcmachineid
    mountPath: /etc/machine-id
    readOnly: true
%{ if local.elasticsearch_tls_enabled ~}
  - name: elasticsearch-certs
    mountPath: ${local.es_certificates_mount_path}
    readOnly: true
%{ endif ~}


command:
  - /fluent-bit/bin/fluent-bit

args:
  - --workdir=/fluent-bit/etc
  - --config=/fluent-bit/etc/conf/fluent-bit.conf

logLevel: info

flush: 1

metricsPort: 2020

EOT
}

resource helm_release fluent_bit {
  chart = "fluent-bit"
  version = var.fluentbit_helm_chart_version
  name = local.fluent_bit_release_name
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  namespace = var.kubernetes_namespace_owned ? kubernetes_namespace.this[0].metadata[0].name : var.kubernetes_namespace_name
  repository = "https://fluent.github.io/helm-charts"
  values = [ local.fluent_bit_values ]
  depends_on = [ helm_release.elasticsearch ]
}