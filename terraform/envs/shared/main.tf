data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_subnetwork" "default" {
  name   = "default"
  region = var.region
}

# MySQL 인스턴스
module "eip_mysql" {
  source       = "../../modules/ip"
  address_name = "babpat-eip-mysql"
  region       = var.region
}

module "compute_mysql" {
  source          = "../../modules/compute"
  instance_name   = "babpat-compute-mysql"
  machine_type    = "e2-standard-2"
  zone            = "asia-northeast3-c"
  nat_ip          = module.eip_mysql.ip_address
  network_id      = data.google_compute_network.default.id
  subnetwork_id   = data.google_compute_subnetwork.default.id

  boot_disk_image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20250312"
  boot_disk_size  = 10
  boot_disk_type  = "pd-balanced"

  tags = ["babpat-mysql"]

  metadata = {
    "enable-osconfig" = "TRUE"
  }
}

module "firewall_mysql" {
  source         = "../../modules/firewall"
  firewall_name  = "babpat-mysql"
  network_id     = data.google_compute_network.default.id
  priority       = 1000
  direction      = "INGRESS"
  description    = "밥팟 mysql 포트"

  allow = [
    {
      protocol = "tcp"
      ports    = ["3306", "9100", "9104"]
    }
  ]

  source_ranges  = ["0.0.0.0/0"]
  source_tags    = []
  target_tags    = ["babpat-mysql"]
}

# Monitoring
module "eip_monitoring" {
  source       = "../../modules/ip"
  address_name = "monitoring-eip"
  region       = var.region
}

module "compute_monitoring" {
  source          = "../../modules/compute"
  instance_name   = "babpat-compute-monitoring"
  machine_type    = "e2-micro"
  zone            = "asia-northeast3-c"
  nat_ip          = module.eip_monitoring.ip_address
  network_id      = data.google_compute_network.default.id
  subnetwork_id   = data.google_compute_subnetwork.default.id

  boot_disk_image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20250312"
  boot_disk_size  = 20
  boot_disk_type  = "pd-balanced"

  tags = ["babpat-monitoring"]

  metadata = {
    "enable-osconfig" = "TRUE"
  }
}

module "firewall_monitoring_server" {
  source         = "../../modules/firewall"
  firewall_name  = "babpat-monitoring-server"
  network_id     = data.google_compute_network.default.id
  priority       = 1000
  direction      = "INGRESS"
  description    = "Monitoring server firewall"

  allow = [
    {
      protocol = "tcp"
      ports    = ["3000", "9090", "9093"]
    }
  ]

  source_ranges  = ["0.0.0.0/0"]
  source_tags    = []
  target_tags    = ["babpat-monitoring"]
}

module "firewall_monitoring_target" {
  source         = "../../modules/firewall"
  firewall_name  = "babpat-monitoring-target"
  network_id     = data.google_compute_network.default.id
  priority       = 1000
  direction      = "INGRESS"
  description    = "Monitoring target firewall rule (shared)"

  allow = [
    {
      protocol = "tcp"
      ports    = ["9100", "8080", "8000", "3000", "9121"]
    }
  ]

  source_ranges = ["34.64.168.196/32"]
  source_tags   = []
  target_tags   = ["babpat-monitoring-target"]
}

module "firewall_redis_server" {
  source         = "../../modules/firewall"
  firewall_name  = "babpat-redis-server"
  network_id     = data.google_compute_network.default.id
  priority       = 1000
  direction      = "INGRESS"
  description    = "Redis server firewall"

  allow = [
    {
      protocol = "tcp"
      ports    = ["6379"]
    }
  ]

  source_ranges = null
  source_tags   = ["babpat-backend"]
  target_tags   = ["babpat-redis"]
}

module "firewall_ilb_health_check" {
  source         = "../../modules/firewall"
  firewall_name  = "test-ilb-health-check"
  network_id     = data.google_compute_network.default.id
  priority       = 900
  direction      = "INGRESS"
  description    = "TEMP: Allow all ingress for ILB health check test"

  allow = [
    {
      protocol = "tcp"
      ports    = ["8000", "8080"]
    }
  ]

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
  source_tags = null
  target_tags = ["babpat-server"]
}