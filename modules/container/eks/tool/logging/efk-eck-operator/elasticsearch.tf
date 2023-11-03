locals {
  elasticsearch_tls_enabled = true
  elasticsearch_service_name = "log-elasticsearch-eck-elasticsearch-es-http"
  elasticsearch_service_port = 9200
  elasticsearch_credentials_k8s_secret_name = "log-elasticsearch-eck-elasticsearch-es-elastic-user"
  elasticsearch_certificates_k8s_secret_name = "log-elasticsearch-eck-elasticsearch-es-http-certs-public"
  # render helm chart values since direct passing of values does not work in all cases
  elasticsearch_values = <<EOT
---
# Default values for eck-elasticsearch.
# This is a YAML-formatted file.

# Overridable names of the Elasticsearch resource.
# By default, this is the Release name set for the chart,
# followed by 'eck-elasticsearch'.
#
# nameOverride will override the name of the Chart with the name set here,
# so nameOverride: quickstart, would convert to '{{ Release.name }}-quickstart'
#
# nameOverride: "quickstart"
#
# fullnameOverride will override both the release name, and the chart name,
# and will name the Elasticsearch resource exactly as specified.
#
# fullnameOverride: "quickstart"

# Version of Elasticsearch.
#
version: ${var.elasticsearch_version}

# Labels that will be applied to Elasticsearch.
#
labels: {}

# Annotations that will be applied to Elasticsearch.
#
annotations: {}

# Settings for configuring Elasticsearch users and roles.
# ref: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-users-and-roles.html
#
auth: {}

# Settings for configuring stack monitoring.
# ref: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-stack-monitoring.html
#
monitoring: {}

# Control the Elasticsearch transport module used for internal communication between nodes.
# ref: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-transport-settings.html
#
transport: {}

# Settings to control how Elasticsearch will be accessed.
# ref: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-accessing-elastic-services.html
#
http: {}

# Control Elasticsearch Secure Settings.
# ref: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-es-secure-settings.html#k8s-es-secure-settings
#
secureSettings: {}

# Settings for limiting the number of simultaneous changes to an Elasticsearch resource.
# ref: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-update-strategy.html
#
updateStrategy: {}

# Controlling of connectivity between remote clusters within the same kubernetes cluster.
# ref: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-remote-clusters.html
#
remoteClusters: {}

# Node configuration settings.
# ref: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-node-configuration.html
#
nodeSets:
- name: masters
  count: 1
  config:
    # On Elasticsearch versions before 7.9.0, replace the node.roles configuration with the following:
    # node.master: true
    node.roles: ["master", "data"]
    xpack.ml.enabled: true
    # Comment out when setting the vm.max_map_count via initContainer, as these are mutually exclusive.
    # For production workloads, it is strongly recommended to increase the kernel setting vm.max_map_count to 262144
    # and leave node.store.allow_mmap unset.
    # ref: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-virtual-memory.html
    #
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
  name = "log-elasticsearch"
  dependency_update = true
  atomic = false
  cleanup_on_fail = false
  namespace = kubernetes_namespace.namespace.metadata[0].name
  values = [ local.elasticsearch_values ]
}