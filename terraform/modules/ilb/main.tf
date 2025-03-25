resource "google_compute_health_check" "this" {
  name                = "${var.name}-hc"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    port = var.service_port
  }
}

resource "google_compute_region_backend_service" "this" {
  name                  = var.name
  load_balancing_scheme = "INTERNAL"
  protocol              = "TCP"
  region                = var.region
  timeout_sec           = 10

  health_checks = [google_compute_health_check.this.self_link]

  backend {
    group = var.instance_group
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_forwarding_rule" "this" {
  name                  = var.name
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.this.self_link
  network               = var.network
  subnetwork            = var.subnetwork
  ports                 = [var.service_port]
  ip_protocol           = "TCP"
  region                = var.region
}