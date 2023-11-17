# -- Installs the AWS specific extensions to NGinX, if necessary

locals {
  nginx_aws_extensions_values = <<EOT
ingress:
%{ if var.load_balancer_strategy == "INGRESS_VIA_ALB" ~}
  enabled: true
  class: alb
  host: ${var.host_name}
  service:
    name: ingress-nginx-controller
loadbalancer:
  name: ${local.alb_name}
  tls:
    certificateArn: ${var.tls_certificate_arn}
  targetGroupSubnets: ${join(",", var.target_group_subnet_ids)}
%{ else ~}
  enabled: false
%{ endif ~}

targetGroupBinding:
%{ if var.load_balancer_strategy == "SERVICE_VIA_TARGET_GROUP_BINDING" ~}
  enabled: true
  targetGroupArn: ${var.target_group_arn}
  service:
    name: ingress-nginx-controller
    port: 80
%{ else ~}
  enabled: false
%{ endif ~}
EOT
}

resource helm_release nginx_aws_extensions {
  count = var.load_balancer_strategy == "INGRESS_VIA_ALB" || var.load_balancer_strategy == "SERVICE_VIA_TARGET_GROUP_BINDING" ? 1 : 0
  chart = "${path.module}/resources/helm/nginx-aws-extensions"
  name = "${var.helm_release_name}-aws-extensions"
  dependency_update = true
  atomic = true
  cleanup_on_fail = true
  wait = true
  create_namespace = false
  namespace = kubernetes_namespace_v1.nginx.metadata[0].name
  values = [ local.nginx_aws_extensions_values ]
  depends_on = [ kubernetes_namespace_v1.nginx, helm_release.nginx ]
}