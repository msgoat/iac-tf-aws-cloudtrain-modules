locals {
  // build map of subnet IDs by zone name
  names_of_zones_with_node_groups = [ for sn in data.aws_subnet.node_group : sn.availability_zone ]
  node_group_subnet_ids = [ for sn in data.aws_subnet.node_group : sn.id ]
  node_group_subnet_ids_by_zone = zipmap(local.names_of_zones_with_node_groups, local.node_group_subnet_ids)
  // normalize given node groups by applying default values for unspecified attributes
  given_node_groups = [ for ng in var.node_groups : {
    name = ng.name
    kubernetes_version = ng.name == "" ? var.kubernetes_version : ng.kubernetes_version
    min_size = ng.min_size
    max_size = ng.max_size
    desired_size = ng.desired_size == 0 ? ng.min_size : ng.desired_size
    disk_size = ng.disk_size
    capacity_type = ng.capacity_type
    instance_types = ng.instance_types
    labels = ng.labels
    taints = ng.taints
  } ]
  // build map of given node groups by node group name
  given_names_of_node_groups = [ for ng in local.given_node_groups : ng.name ]
  given_node_groups_by_name = zipmap(local.given_names_of_node_groups, local.given_node_groups)
  // replicate given node groups by zones
  node_groups_per_zone = [ for pair in setproduct(local.names_of_zones_with_node_groups, local.given_names_of_node_groups) : {
    zone_name = pair[0]
    given_node_group_name = pair[1]
    node_group_key = "${pair[0]}-${pair[1]}"
  } ]
  // build map of node group templates by node group key
  node_group_template_keys = [ for ng in local.node_groups_per_zone : ng.node_group_key ]
  node_group_template_values = [ for ng in local.node_groups_per_zone : {
    node_group_key = ng.node_group_key
    node_group_name = "mng-${ng.zone_name}-${var.solution_fqn}-${var.kubernetes_cluster_name}-${ng.given_node_group_name}"
    kubernetes_version = local.given_node_groups_by_name[ng.given_node_group_name].kubernetes_version
    min_size = local.given_node_groups_by_name[ng.given_node_group_name].min_size
    max_size = local.given_node_groups_by_name[ng.given_node_group_name].max_size
    desired_size = local.given_node_groups_by_name[ng.given_node_group_name].desired_size
    disk_size = local.given_node_groups_by_name[ng.given_node_group_name].disk_size
    capacity_type = local.given_node_groups_by_name[ng.given_node_group_name].capacity_type
    instance_types = local.given_node_groups_by_name[ng.given_node_group_name].instance_types
    zone_name = ng.zone_name
    subnet_id = local.node_group_subnet_ids_by_zone[ng.zone_name]
    labels = local.given_node_groups_by_name[ng.given_node_group_name].labels
    taints = local.given_node_groups_by_name[ng.given_node_group_name].taints
  } ]
  node_group_templates = zipmap(local.node_group_template_keys, local.node_group_template_values)
}

// create node groups from node group templates
resource aws_eks_node_group node_groups {
  for_each = local.node_group_templates
  node_group_name = each.value.node_group_name
  cluster_name = aws_eks_cluster.control_plane.name
  subnet_ids = [ each.value.subnet_id ]
  version = each.value.kubernetes_version
  node_role_arn = aws_iam_role.node_group.arn
  disk_size = each.value.disk_size
  instance_types = each.value.instance_types
  capacity_type = each.value.capacity_type
  tags = merge({
    Name = each.value.node_group_name
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

  depends_on = [
    aws_vpc_endpoint.private_ec2,
    aws_vpc_endpoint.private_ecr_api,
    aws_vpc_endpoint.private_ecr_docker,
    aws_vpc_endpoint.private_s3
  ]
}
