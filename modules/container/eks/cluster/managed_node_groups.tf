locals {
  enabled_node_group_templates = [for ngt in var.node_group_templates : ngt if ngt.enabled]
  single_multi_az_node_group_templates = [for ngt in local.enabled_node_group_templates : {
    node_group_key           = ngt.name
    node_group_template_name = ngt.name
    kubernetes_version       = ngt.kubernetes_version == null ? var.kubernetes_version : ngt.kubernetes_version
    min_size                 = ngt.min_size
    max_size                 = ngt.max_size
    desired_size             = ngt.desired_size == 0 ? ngt.min_size : ngt.desired_size
    disk_size                = ngt.disk_size
    capacity_type            = ngt.capacity_type
    instance_types           = ngt.instance_types
    subnet_ids               = var.node_group_subnet_ids
    labels                   = ngt.labels
    taints                   = ngt.taints
  }]
  multi_single_az_node_group_templates = [for i, pair in setproduct(local.single_multi_az_node_group_templates, var.node_group_subnet_ids) : {
    node_group_key           = "${pair[0].node_group_key}-${pair[1]}"
    node_group_template_name = pair[0].node_group_template_name
    kubernetes_version       = pair[0].kubernetes_version
    min_size                 = pair[0].min_size
    max_size                 = pair[0].max_size
    desired_size             = pair[0].desired_size
    disk_size                = pair[0].disk_size
    capacity_type            = pair[0].capacity_type
    instance_types           = pair[0].instance_types
    subnet_ids               = [pair[1]]
    labels                   = pair[0].labels
    taints                   = pair[0].taints
  }]
  // build map of node group templates by node group key
  node_group_template_values  = var.node_group_strategy == "MULTI_SINGLE_AZ" ? local.multi_single_az_node_group_templates : local.single_multi_az_node_group_templates
  node_group_template_keys    = [for ngt in local.node_group_template_values : ngt.node_group_key]
  node_group_templates_by_key = zipmap(local.node_group_template_keys, local.node_group_template_values)
}

// create node groups from node group templates
resource "aws_eks_node_group" "node_groups" {
  for_each        = local.node_group_templates_by_key
  node_group_name = each.key
  cluster_name    = aws_eks_cluster.control_plane.name
  subnet_ids      = each.value.subnet_ids
  version         = each.value.kubernetes_version
  node_role_arn   = aws_iam_role.node_group.arn
  disk_size       = each.value.disk_size
  instance_types  = each.value.instance_types
  capacity_type   = each.value.capacity_type
  tags = merge({
    Name                                = each.key
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.control_plane.name}" : "owned"
  }, local.module_common_tags)

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable_percentage = 33
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  labels = each.value.labels

  dynamic "taint" {
    for_each = toset(each.value.taints)
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
}
