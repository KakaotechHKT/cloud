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
    "babpat-monitoring-target",
    "babpat-redis"
  ]
  metadata = {
    "enable-osconfig" = "TRUE"
  }
}

module "private_subnet" {
  source        = "../../modules/subnet"
  name          = "babpat-private-subnet"
  region        = var.region
  network       = data.google_compute_network.default.id
  ip_cidr_range = "10.10.0.0/20"
}

module "nat" {
  source                          = "../../modules/nat"
  name                            = "babpat-nat"
  region                          = var.region
  network                         = data.google_compute_network.default.id
  tcp_established_idle_timeout_sec = 2100
}

module "mig_backend" {
  source                  = "../../modules/mig"
  name                    = "babpat-be"
  instance_template       = "babpat-be-template-${local.be_template_suffix}"
  min_replicas            = 1
  max_replicas            = 2
  target_cpu_utilization  = 0.6
  region                  = var.region
  ports                   = ["8080"]
  port_name               = "http"
  health_check_port       = 8080
  tags                    = ["babpat-monitoring-target", "babpat-backend", "babpat-server"]
  network_id              = data.google_compute_network.default.id
  subnetwork_id           = module.private_subnet.self_link
  no_external_ip          = true
  service_account_email   = "697671643244-compute@developer.gserviceaccount.com"
  source_image            = "projects/${var.project}/global/images/babpat-backend-image-img"
  startup_script          = <<-EOT
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
  source         = "../../modules/ilb"
  name           = "babpat-be-ilb"
  region         = var.region
  network        = data.google_compute_network.default.id
  subnetwork     = data.google_compute_subnetwork.default.id
  service_port   = 8080
  instance_group = module.mig_backend.instance_group
}

module "mig_ai" {
  source                  = "../../modules/mig"
  name                    = "babpat-ai"
  instance_template       = "babpat-ai-template-${local.ai_template_suffix}"
  min_replicas            = 1
  max_replicas            = 2
  target_cpu_utilization  = 0.6
  region                  = var.region
  ports                   = ["8000"]
  port_name               = "http"
  health_check_port       = 8000
  tags                    = ["babpat-monitoring-target", "babpat-server"]
  network_id              = data.google_compute_network.default.id
  subnetwork_id           = module.private_subnet.self_link
  no_external_ip          = true
  service_account_email   = "697671643244-compute@developer.gserviceaccount.com"
  source_image            = "projects/${var.project}/global/images/babpat-ai-image-img"
  startup_script          = <<-EOT
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
  source         = "../../modules/ilb"
  name           = "babpat-ai-ilb"
  region         = var.region
  network        = data.google_compute_network.default.id
  subnetwork     = data.google_compute_subnetwork.default.id
  service_port   = 8000
  instance_group = module.mig_ai.instance_group
}