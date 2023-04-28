locals {
  long_alb_name = "alb-${var.eks_cluster_name}"
  short_alb_name = "alb-eks-${random_id.alb.hex}"
  alb_name = length(local.long_alb_name) <= 32 ? local.long_alb_name : local.short_alb_name
}

data aws_alb managed {
  count = var.load_balancer_strategy == "INGRESS_VIA_ALB" ? 1 : 0
  name = local.alb_name
  depends_on = [ helm_release.nginx ]
}

resource random_id alb {
  byte_length = 8
}
