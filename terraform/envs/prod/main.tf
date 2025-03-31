data "google_compute_network" "default" {
  name    = "default"
  project = var.project
}

data "google_compute_subnetwork" "default" {
  name    = "default"
  region  = var.region
  project = var.project
}

locals {
  be_template_suffix = "202503262000"
  ai_template_suffix = "202503261200"
}

module "eip_prod" {
  source       = "../../modules/ip"
  address_name = "babpat-eip-prod"
  region       = var.region
}

# prod Compute
module "compute_prod" {
  source          = "../../modules/compute"

  instance_name   = "babpat-compute-prod"
  machine_type    = "e2-medium"
  zone            = "asia-northeast3-c"
  nat_ip          = module.eip_prod.ip_address
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