locals {
  ingress_controller_configs = {
    NGINX = {
      traffic_port = var.ingress_controller_secure ? 443 : 80
      traffic_protocol = var.ingress_controller_secure ? "https" : "http"
      health_probe_path = "/healthz"
      health_probe_port = var.ingress_controller_secure ? 443 : 80
      health_probe_protocol = var.ingress_controller_secure ? "https" : "http"
      health_probe_matcher = "200,400"
    }
  }
  given_ingress_controller_config = local.ingress_controller_configs[var.ingress_controller_type]
}