# eks_cluster_security_group_rules.tf
# ----------------------------------------------------------------------------
# Since AWS does not propagate custom cluster security groups to the nodes
# in the managed node groups, we have to extend the cluster security group
# with additional rules in order to allow traffic from the loadbalancer
# to the ingress controller running on the managed node groups.
# ----------------------------------------------------------------------------

# retrieve the EKS managed security group attached to all managed worker nodes
data aws_security_group cluster {
  count = var.eks_cluster_name != "" ? 1 : 0
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    "aws:eks:cluster-name" = var.eks_cluster_name
  }
}

# allow traffic from loadbalancer to ingress controller on given target group port
resource aws_security_group_rule allow_traffic_from_lb_to_ingress_controller {
  count = var.eks_cluster_name != "" ? 1 : 0
  description = "allow traffic from loadbalancer to ingress controller"
  security_group_id = data.aws_security_group.cluster[0].id
  from_port = var.target_group.port
  to_port = var.target_group.port
  protocol = "TCP"
  type = "ingress"
  source_security_group_id = aws_security_group.loadbalancer.id
}

# allow health checks from loadbalancer to ingress controller on given health check port
resource aws_security_group_rule allow_health_check_from_lb_to_ingress_controller {
  count = var.eks_cluster_name != "" ? 1 : 0
  description = "allow health check from loadbalancer to ingress controller"
  security_group_id = data.aws_security_group.cluster[0].id
  from_port = var.target_group_health_check.port
  to_port = var.target_group_health_check.port
  protocol = "TCP"
  type = "ingress"
  source_security_group_id = aws_security_group.loadbalancer.id
}