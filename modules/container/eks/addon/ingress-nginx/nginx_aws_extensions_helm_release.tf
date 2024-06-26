# -- Installs the AWS specific extensions to NGinX, if necessary

locals {
  nginx_aws_extensions_values = <<EOT
ingress:
%{if var.load_balancer_strategy == "INGRESS_VIA_ALB"~}
  enabled: true
  class: aws
  host: ${var.host_names[0]}
  service:
    name: ingress-nginx-controller
loadbalancer:
  name: ${local.alb_name}
  tls:
    certificateArn: ${var.tls_certificate_arn}
  targetGroupSubnets: ${join(",", var.target_group_subnet_ids)}
%{else~}
  enabled: false
%{endif~}

targetGroupBinding:
%{if var.load_balancer_strategy == "SERVICE_VIA_TARGET_GROUP_BINDING"~}
  enabled: true
  targetGroupArn: ${aws_lb_target_group.ingress[0].arn}
  targetType: ${var.loadbalancer_target_type}
  service:
    name: ingress-nginx-controller
    port: 80
%{else~}
  enabled: false
%{endif~}
EOT
}

resource "helm_release" "nginx_aws_extensions" {
  count             = var.load_balancer_strategy == "INGRESS_VIA_ALB" || var.load_balancer_strategy == "SERVICE_VIA_TARGET_GROUP_BINDING" ? 1 : 0
  chart             = "${path.module}/resources/helm/nginx-aws-extensions"
  name              = "${var.helm_release_name}-aws-extensions"
  dependency_update = true
  atomic            = true
  cleanup_on_fail   = true
  wait              = true
  create_namespace  = false
  namespace         = var.kubernetes_namespace_owned ? kubernetes_namespace_v1.nginx[0].metadata[0].name : var.kubernetes_namespace_name
  values            = [local.nginx_aws_extensions_values]
  depends_on        = [helm_release.nginx]
}