resource "google_compute_subnetwork" "this" {
  name                     = var.name
  region                   = var.region
  network                  = var.network
  ip_cidr_range            = var.ip_cidr_range
  private_ip_google_access = true
}