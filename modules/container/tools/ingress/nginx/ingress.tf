resource kubernetes_ingress_v1 nginx {
  count = var.load_balancer_strategy == "INGRESS_VIA_ALB" ? 1 : 0
  metadata {
    name = "${var.helm_release_name}-controller"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/load-balancer-name" = "alb-${var.region_name}-${var.solution_fqn}-eks"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port" = "traffic-port"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "10"
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" = "5"
      "alb.ingress.kubernetes.io/success-codes" = "200,404"
      "alb.ingress.kubernetes.io/certificate-arn" = var.tls_certificate_arn
      "alb.ingress.kubernetes.io/ssl-policy" = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    }
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance" = var.helm_release_name
      "app.kubernetes.io/managed-by" = "Terraform"
      "app.kubernetes.io/name" = var.helm_release_name
      "app.kubernetes.io/part-of" = var.helm_release_name
    }
    namespace = kubernetes_namespace_v1.nginx.metadata[0].name
  }
  spec {
    ingress_class_name = "alb"
    rule {
      host = var.host_name
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.helm_release_name}-controller"
              port {
                number = "80"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [ helm_release.nginx ]
}