output "ip_address" {
  description = "The allocated static IP address"
  value       = google_compute_address.this.address
}

output "address_name" {
  description = "Name of the static IP address"
  value       = google_compute_address.this.name
}
