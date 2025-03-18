# --------------------------------------------------
# dev
# --------------------------------------------------
resource "google_compute_instance" "babpat_compute_dev" {
  name         = "babpat-compute-dev"
  machine_type = "e2-small"
  zone         = "asia-northeast3-c"

  key_revocation_action_type = "NONE"
  labels                     = {}
  resource_policies          = []

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20250312"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = data.google_compute_network.default.id
    subnetwork = data.google_compute_subnetwork.default.id
    access_config {
      nat_ip = google_compute_address.eip_dev.address
    }
  }

  tags = ["http-server", "https-server"]

  metadata = {
    "enable-osconfig" = "TRUE"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

#   reservation_affinity {
#     type = "ANY_RESERVATION"
#   }

  # service_account {
  #   email  = "697671643244-compute@developer.gserviceaccount.com"
  #   scopes = [
  #     "https://www.googleapis.com/auth/devstorage.read_only",
  #     "https://www.googleapis.com/auth/logging.write",
  #     "https://www.googleapis.com/auth/monitoring.write",
  #     "https://www.googleapis.com/auth/service.management.readonly",
  #     "https://www.googleapis.com/auth/servicecontrol",
  #     "https://www.googleapis.com/auth/trace.append"
  #   ]
  # }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  lifecycle {
    ignore_changes = [
      service_account
    #   cpu_platform,
    #   creation_timestamp,
    #   current_status,
    #   metadata_fingerprint,
    #   min_cpu_platform,
    #   self_link,
    #   tags_fingerprint,
    #   boot_disk[0].device_name,
    #   boot_disk[0].source,
    #   boot_disk[0].initialize_params["provisioned_iops"],
    #   boot_disk[0].initialize_params["provisioned_throughput"],
    #   key_revocation_action_type
    #   enable_display
    ]
  }
}

# --------------------------------------------------
# prod
# --------------------------------------------------
resource "google_compute_instance" "babpat_compute_prod" {
  name         = "babpat-compute-prod"
  machine_type = "e2-medium"
  zone         = "asia-northeast3-c"

  key_revocation_action_type = "NONE"
  labels            = {}
  resource_policies = []

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20250312"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = data.google_compute_network.default.id
    subnetwork = data.google_compute_subnetwork.default.id
    access_config {
      nat_ip = google_compute_address.eip_prod.address
    }
  }

  tags = ["http-server", "https-server"]

  metadata = {
    "enable-osconfig" = "TRUE"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  lifecycle {
    ignore_changes = [
      service_account
    ]
  }
}

# --------------------------------------------------
# MySQL
# --------------------------------------------------
resource "google_compute_instance" "babpat_compute_mysql" {
  name         = "babpat-compute-mysql"
  machine_type = "e2-small"
  zone         = "asia-northeast3-c"

  key_revocation_action_type = "NONE"
  labels            = {}
  resource_policies = []

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20250312"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = data.google_compute_network.default.id
    subnetwork = data.google_compute_subnetwork.default.id
    access_config {
      nat_ip = google_compute_address.eip_mysql.address
    }
  }

  tags = ["babpat-mysql"]

  metadata = {
    "enable-osconfig" = "TRUE"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  lifecycle {
    ignore_changes = [
      service_account
    ]
  }
}
