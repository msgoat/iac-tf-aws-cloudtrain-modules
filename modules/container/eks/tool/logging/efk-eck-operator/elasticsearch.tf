locals {
  elasticsearch_release_name = "${var.helm_release_name}-elasticsearch"
  elasticsearch_tls_enabled = true
  elasticsearch_service_name = "${local.elasticsearch_release_name}-es-http"
  elasticsearch_service_port = 9200
  elasticsearch_credentials_k8s_secret_name = "${local.elasticsearch_release_name}-es-elastic-user"
  elasticsearch_certificates_k8s_secret_name = "${local.elasticsearch_release_name}-es-http-certs-public"
  elasticsearch_replica_count = var.ensure_high_availability && var.elasticsearch_cluster_size < 3 ? 3 : var.elasticsearch_cluster_size
  # render helm chart values since direct passing of values does not work in all cases
  elasticsearch_values = <<EOT
fullnameOverride: "${local.elasticsearch_release_name}"
version: ${var.elasticsearch_version}
labels: {}
annotations: {}
auth: {}
monitoring: {}
transport: {}
http: {}
secureSettings: {}
updateStrategy: {}
remoteClusters: {}
nodeSets:
- name: masters
  count: ${local.elasticsearch_replica_count}
  config:
    node.roles: ["master", "data"]
    xpack.ml.enabled: true
    node.store.allow_mmap: false
  podTemplate:
    spec:
      containers:
      - name: elasticsearch
        resources:
          requests:
            cpu: 1      # TODO: make configurable
            memory: 2Gi # TODO: make configurable
          limits:
            memory: 2Gi
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
  volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data # Do not change this name unless you set up a volume mount for the data path.
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: ${var.elasticsearch_storage_size}Gi
        storageClassName: ${var.elasticsearch_storage_class}
EOT
}

resource helm_release elasticsearch {
  chart = "${path.module}/resources/helm/eck-elasticsearch"
  name = local.elasticsearch_release_name
  dependency_update = true
  atomic = false
  cleanup_on_fail = false
  namespace = var.kubernetes_namespace_owned ? kubernetes_namespace.this[0].metadata[0].name : var.kubernetes_namespace_name
  values = [ local.elasticsearch_values ]
}