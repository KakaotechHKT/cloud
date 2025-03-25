data "google_compute_network" "default" {
  name    = "default"
  project = var.project
}

data "google_compute_subnetwork" "default" {
  name    = "default"
  region  = var.region
  project = var.project
}

module "eip_dev" {
  source       = "../../modules/ip"
  address_name = "babpat-eip-dev"
  region       = var.region
}

module "compute_dev" {
  source          = "../../modules/compute"
  instance_name   = "babpat-compute-dev"
  machine_type    = "e2-small"
  zone            = "asia-northeast3-c"
  nat_ip          = module.eip_dev.ip_address
  network_id      = data.google_compute_network.default.id
  subnetwork_id   = data.google_compute_subnetwork.default.id

  boot_disk_image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20250312"
  boot_disk_size  = 10
  boot_disk_type  = "pd-balanced"

  tags = [
    "http-server",
    "https-server",
    "babpat-monitoring-target"
  ]

  metadata = {
    "enable-osconfig" = "TRUE"
  }
}