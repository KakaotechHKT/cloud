output "firewall_id" {
  description = "ID of the firewall rule"
  value       = google_compute_firewall.this.id
}

output "firewall_name" {
  description = "Name of the firewall rule"
  value       = google_compute_firewall.this.name
}
