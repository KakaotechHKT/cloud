resource "google_compute_firewall" "this" {
  name    = var.firewall_name
  network = var.network_id

  priority  = var.priority
  direction = var.direction

  description = var.description

  dynamic "allow" {
    for_each = var.allow
    content {
      protocol = allow.value["protocol"]
      ports    = allow.value["ports"]
    }
  }

  source_ranges = var.source_ranges
  source_tags = var.source_tags
  target_tags   = var.target_tags

  lifecycle {
    ignore_changes = [description]
  }
}
