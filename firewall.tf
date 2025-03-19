# --------------------------------------------------
# MySQL 방화벽 정책
# --------------------------------------------------
resource "google_compute_firewall" "babpat_mysql" {
  name    = "babpat-mysql"
  network = data.google_compute_network.default.id

  priority  = 1000
  direction = "INGRESS"
  
  description = "밥팟 mysql 포트"

  allow {
    protocol = "tcp"
    ports    = ["3306", "9100", "9104"] # mysql, node exporter, mysql exporter
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["babpat-mysql"]

  lifecycle {
    ignore_changes = [description]
  }
}

# --------------------------------------------------
# 모니터링 서버 방화벽 정책
# --------------------------------------------------
resource "google_compute_firewall" "babpat_monitoring_server" {
  name    = "babpat-monitoring-server"
  network = data.google_compute_network.default.id

  priority  = 1000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["3000", "9090"] # grafana, prometheus
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["babpat-monitoring"]
  lifecycle {
    ignore_changes = [description]
  }
}

# --------------------------------------------------
# 모니터링 타겟 방화벽 정책
# --------------------------------------------------
resource "google_compute_firewall" "babpat_monitoring_target" {
  name    = "babpat-monitoring-target"
  network = data.google_compute_network.default.id

  priority  = 1000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [
        "9100", # node exporter
        "8080", # backend http
        "8000", # ai http
        "3000", # frontend http
        "9121", # redis exporter
    ]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["babpat-monitoring-target"]
}