locals {
  enabled_node_group_templates = [for ngt in var.node_group_templates : ngt if ngt.enabled]
  // build map of node group templates by node group key
  enabled_node_group_template_keys = [for ngt in local.enabled_node_group_templates : ngt.name ]
  enabled_node_group_templates_by_key = zipmap(local.enabled_node_group_template_keys, local.enabled_node_group_templates)
}

// create node groups from node group templates
resource aws_eks_node_group node_groups {
  for_each = local.enabled_node_group_templates_by_key
  node_group_name = "mng-${local.eks_cluster_name}-${each.key}"
  cluster_name = aws_eks_cluster.control_plane.name
  subnet_ids = each.value.subnet_ids
  version = each.value.kubernetes_version
  node_role_arn = aws_iam_role.node_group.arn
  disk_size = each.value.disk_size
  instance_types = each.value.instance_types
  capacity_type = each.value.capacity_type
  tags = merge({
    Name = "mng-${local.eks_cluster_name}-${each.key}"
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.control_plane.name}": "owned"
  }, local.module_common_tags)

  scaling_config {
    desired_size = each.value.desired_size
    max_size = each.value.max_size
    min_size = each.value.min_size
  }

  update_config {
    max_unavailable_percentage = 33
  }

  lifecycle {
    ignore_changes = [ scaling_config[0].desired_size ]
  }

  dynamic taint {
    for_each = toset(each.value.taints)
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
}
