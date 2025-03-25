resource "google_compute_instance_template" "this" {
  name_prefix   = var.instance_template
  machine_type  = "e2-small"
  tags          = var.tags
  region        = var.region

  disk {
    auto_delete  = true
    boot         = true
    source_image = var.source_image
    disk_type    = "pd-balanced"
    disk_size_gb = 10
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id

    dynamic "access_config" {
      for_each = var.no_external_ip ? [] : [1]
      content {}
    }
  }

  metadata = {
    enable-osconfig = "TRUE"
    startup-script = var.startup_script
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "this" {
  name                = "${var.name}-hc"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    port = var.health_check_port
  }
}

resource "google_compute_region_instance_group_manager" "this" {
  name               = var.name
  base_instance_name = var.name
  region             = var.region

  version {
    instance_template = google_compute_instance_template.this.self_link
  }

  named_port {
    name = var.port_name              # 예: "http"
    port = tonumber(var.ports[0])     # 예: 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.this.self_link
    initial_delay_sec = 60
  }
}

resource "google_compute_region_autoscaler" "this" {
  name   = "${var.name}-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.this.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = 60

    cpu_utilization {
      target = var.target_cpu_utilization
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      autoscaling_policy[0].metric  # memory 관련 변경 무시
    ]
  }
}