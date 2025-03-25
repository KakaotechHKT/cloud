terraform {
  backend "gcs" {
    bucket  = "terraform-state-1q2w3e4r"
    prefix  = "terraform/state"
  }
}

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

module "service_account_ops_agent" {
  source       = "./modules/iam"

  name         = "babpat-ops-agent"
  display_name = "Ops Agent for babpat"
  project_id   = var.project
  roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer"
  ]
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
    "babpat-monitoring-target",
    "babpat-redis"
  ]

  metadata = {
    "enable-osconfig" = "TRUE"
  }
}

# prod 환경에서만 Private Subnet + NAT 생성
module "private_subnet" {
  source          = "./modules/subnet"
  count           = local.environment == "prod" ? 1 : 0
  name            = "babpat-private-subnet"
  region          = var.region
  network         = data.google_compute_network.default.id
  ip_cidr_range   = "10.10.0.0/20"
}

module "nat" {
  source  = "./modules/nat"
  count   = local.environment == "prod" ? 1 : 0
  name    = "babpat-nat"
  region  = var.region
  network = data.google_compute_network.default.id
  tcp_established_idle_timeout_sec = 2100
}

########################
# prod 환경 - Backend MIG + ILB
########################
module "mig_backend" {
  source             = "./modules/mig"
  count              = local.environment == "prod" ? 1 : 0
  name               = "babpat-be"
  instance_template  = "babpat-be-template"
  min_replicas       = 2
  max_replicas       = 5
  target_cpu_utilization = 0.6
  region             = var.region
  ports              = ["8080"]
  port_name          = "http"
  health_check_port  = 8080
  tags               = ["babpat-monitoring-target", "babpat-backend", "babpat-server"]
  network_id         = data.google_compute_network.default.id
  subnetwork_id      = module.private_subnet[0].self_link
  no_external_ip     = true
  source_image       = "projects/${var.project}/global/images/babpat-backend-image-img"
  startup_script     = <<-EOT
    #!/bin/bash
    set -e

    echo "🔹 Docker 이미지 로드 및 실행"
    systemctl start docker || true
    docker load < /opt/app/app.tar
    docker run -d --name babpat-backend -p 8080:8080 \
      --env-file /opt/app/.env \
      --network host \
      --restart unless-stopped \
      yunabyte/babpat-backend:latest
    echo "✅ 컨테이너 실행 완료"

    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
  EOT
}

module "ilb_backend" {
  source         = "./modules/ilb"
  count          = local.environment == "prod" ? 1 : 0
  name           = "babpat-be-ilb"
  region         = var.region
  network        = data.google_compute_network.default.id
  subnetwork     = data.google_compute_subnetwork.default.id
  service_port   = 8080
  instance_group = module.mig_backend[0].instance_group
}

########################
# prod 환경 - AI MIG + ILB
########################
module "mig_ai" {
  source             = "./modules/mig"
  count              = local.environment == "prod" ? 1 : 0
  name               = "babpat-ai"
  instance_template  = "babpat-ai-template"
  min_replicas           = 2
  max_replicas           = 5
  target_cpu_utilization = 0.6
  region             = var.region
  ports              = ["8000"]
  port_name          = "http"
  health_check_port  = 8000
  tags               = ["babpat-monitoring-target", "babpat-server"]
  network_id         = data.google_compute_network.default.id
  subnetwork_id      = module.private_subnet[0].self_link
  no_external_ip     = true
  source_image       = "projects/${var.project}/global/images/babpat-ai-image-img"
  startup_script     = <<-EOT
    #!/bin/bash
    set -e

    echo "🔹 AI Docker 이미지 로드 및 실행"
    systemctl start docker || true
    docker load < /opt/app/app.tar
    docker run -d --name babpat-ai -p 8000:8000 \
      --env-file /opt/app/.env \
      --network host \
      --restart unless-stopped \
      yunabyte/babpat-ai:latest
    echo "✅ 컨테이너 실행 완료"

    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
  EOT
}

module "ilb_ai" {
  source         = "./modules/ilb"
  count          = local.environment == "prod" ? 1 : 0
  name           = "babpat-ai-ilb"
  region         = var.region
  network        = data.google_compute_network.default.id
  subnetwork     = data.google_compute_subnetwork.default.id
  service_port   = 8000
  instance_group = module.mig_ai[0].instance_group
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
  source_tags    = []
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
  source_tags    = []
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

  source_ranges  = ["34.64.168.196/32"]
  source_tags    = []
  target_tags    = ["babpat-monitoring-target"]
}

module "firewall_redis_server" {
  source        = "./modules/firewall"
  count         = local.environment == "shared" ? 1 : 0

  firewall_name = "babpat-redis-server"
  network_id    = data.google_compute_network.default.id
  priority      = 1000
  direction     = "INGRESS"
  description   = "Redis server firewall"

  allow = [
    {
      protocol = "tcp"
      ports    = ["6379"]
    }
  ]

  source_ranges  = null
  source_tags    = ["babpat-backend"]
  target_tags    = ["babpat-redis"]
}

module "firewall_ilb_health_check" {
  source        = "./modules/firewall"
  count         = local.environment == "shared" ? 1 : 0

  firewall_name = "test-ilb-health-check"
  network_id    = data.google_compute_network.default.id
  priority      = 900
  direction     = "INGRESS"
  description   = "TEMP: Allow all ingress for ILB health check test"

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
  target_tags   = ["babpat-server"]
}