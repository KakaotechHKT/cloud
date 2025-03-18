resource "google_compute_firewall" "babpat_mysql" {
  name    = "babpat-mysql"
  network = data.google_compute_network.default.id

  priority  = 1000
  direction = "INGRESS"
  
  description = "밥팟 mysql 포트"

  allow {
    protocol = "tcp"
    ports    = ["3306", "3307"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["babpat-mysql"]

  lifecycle {
    ignore_changes = [description]
  }
}