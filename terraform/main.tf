########################
# 공통 설정
########################
locals {
  environment = terraform.workspace
}

# default VPC가 이미 있다고 가정
data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_subnetwork" "default" {
  name   = "default"
  region = var.region
}


########################
# dev 환경
########################
# dev IP
module "eip_dev" {
  source       = "./modules/ip"
  count        = local.environment == "dev" ? 1 : 0
  address_name = "babpat-eip-dev"
  region       = var.region
}

# dev Compute
module "compute_dev" {
  source          = "./modules/compute"
  count           = local.environment == "dev" ? 1 : 0

  instance_name   = "babpat-compute-dev"
  machine_type    = "e2-small"
  zone            = "asia-northeast3-c"
  nat_ip          = local.environment == "dev" ? module.eip_dev[0].ip_address : null
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

########################
# prod 환경
########################
# prod IP
module "eip_prod" {
  source       = "./modules/ip"
  count        = local.environment == "prod" ? 1 : 0
  address_name = "babpat-eip-prod"
  region       = var.region
}

# prod Compute
module "compute_prod" {
  source          = "./modules/compute"
  count           = local.environment == "prod" ? 1 : 0

  instance_name   = "babpat-compute-prod"
  machine_type    = "e2-medium"
  zone            = "asia-northeast3-c"
  nat_ip          = local.environment == "prod" ? module.eip_prod[0].ip_address : null
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

########################
# shared 환경
########################
# MySQL IP
module "eip_mysql" {
  source       = "./modules/ip"
  count        = local.environment == "shared" ? 1 : 0
  address_name = "babpat-eip-mysql"
  region       = var.region
}

# MySQL Compute
module "compute_mysql" {
  source          = "./modules/compute"
  count           = local.environment == "shared" ? 1 : 0

  instance_name   = "babpat-compute-mysql"
  machine_type    = "e2-small"
  zone            = "asia-northeast3-c"
  nat_ip          = local.environment == "shared" ? module.eip_mysql[0].ip_address : null
  network_id      = data.google_compute_network.default.id
  subnetwork_id   = data.google_compute_subnetwork.default.id

  boot_disk_image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20250312"
  boot_disk_size  = 10
  boot_disk_type  = "pd-balanced"

  tags = [
    "babpat-mysql"
  ]

  metadata = {
    "enable-osconfig" = "TRUE"
  }
}

module "firewall_mysql" {
  source        = "./modules/firewall"
  count         = local.environment == "shared" ? 1 : 0

  firewall_name = "babpat-mysql"
  network_id    = data.google_compute_network.default.id
  priority      = 1000
  direction     = "INGRESS"
  description   = "밥팟 mysql 포트"

  allow = [
    {
      protocol = "tcp"
      ports    = ["3306", "9100", "9104"]
    }
  ]

  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["babpat-mysql"]
}


# Monitoring IP
module "eip_monitoring" {
  source       = "./modules/ip"
  count        = local.environment == "shared" ? 1 : 0
  address_name = "monitoring-eip"
  region       = var.region
}

# Monitoring Compute
module "compute_monitoring" {
  source          = "./modules/compute"
  count           = local.environment == "shared" ? 1 : 0

  instance_name   = "babpat-compute-monitoring"
  machine_type    = "e2-micro"
  zone            = "asia-northeast3-c"
  nat_ip          = local.environment == "shared" ? module.eip_monitoring[0].ip_address : null
  network_id      = data.google_compute_network.default.id
  subnetwork_id   = data.google_compute_subnetwork.default.id

  boot_disk_image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20250312"
  boot_disk_size  = 20
  boot_disk_type  = "pd-balanced"

  tags = [
    "babpat-monitoring"
  ]

  metadata = {
    "enable-osconfig" = "TRUE"
  }
}

module "firewall_monitoring_server" {
  source        = "./modules/firewall"
  count         = local.environment == "shared" ? 1 : 0

  firewall_name = "babpat-monitoring-server"
  network_id    = data.google_compute_network.default.id
  priority      = 1000
  direction     = "INGRESS"
  description   = "Monitoring server firewall"

  allow = [
    {
      protocol = "tcp"
      ports    = ["3000", "9090", "9093"]
    }
  ]

  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["babpat-monitoring"]
}

module "firewall_monitoring_target" {
  source        = "./modules/firewall"
  count         = local.environment == "shared" ? 1 : 0

  firewall_name = "babpat-monitoring-target"
  network_id    = data.google_compute_network.default.id
  priority      = 1000
  direction     = "INGRESS"
  description   = "Monitoring target firewall rule (shared)"

  allow = [
    {
      protocol = "tcp"
      ports    = ["9100", "8080", "8000", "3000", "9121"]
    }
  ]

  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["babpat-monitoring-target"]
}