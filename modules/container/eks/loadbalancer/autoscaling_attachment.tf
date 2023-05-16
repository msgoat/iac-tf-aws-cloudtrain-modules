# attach all autoscaling groups representing managed node groups of an EKS cluster to the target group
resource aws_autoscaling_attachment node_groups_as_targets {
  count = length(data.aws_autoscaling_groups.node_groups.names)
  autoscaling_group_name = data.aws_autoscaling_groups.node_groups.names[count.index]
  lb_target_group_arn = aws_lb_target_group.ingress_controller.arn
}