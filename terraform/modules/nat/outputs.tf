output "name" {
  value = google_compute_router_nat.this.name
}

output "router_name" {
  value = google_compute_router.this.name
}

output "router_self_link" {
  value = google_compute_router.this.self_link
}

output "nat_ip_allocate_option" {
  value = google_compute_router_nat.this.nat_ip_allocate_option
}