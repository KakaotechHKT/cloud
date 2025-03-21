resource "google_compute_address" "this" {
  name   = var.address_name
  region = var.region

  lifecycle {
    ignore_changes = [description]
  }
}
