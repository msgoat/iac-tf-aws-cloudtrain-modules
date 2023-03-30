output ingress_controller {
  description = "Metadata defining the endpoints of the newly created ingress controller"
  value = {
    name = "traefik"
    protocol = "HTTP"
    port = 32080
    health_probe_path = "/ping"
    health_probe_protocol = "HTTP"
    health_probe_port = 32090
  }
}