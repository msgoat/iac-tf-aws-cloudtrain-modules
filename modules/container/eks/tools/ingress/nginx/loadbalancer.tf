data aws_alb managed {
  count = var.load_balancer_strategy == "INGRESS_VIA_ALB" ? 1 : 0
  name = local.alb_name
  depends_on = [ kubernetes_ingress_v1.nginx[0] ]
}