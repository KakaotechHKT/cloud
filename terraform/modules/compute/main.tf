resource "google_compute_instance" "this" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  key_revocation_action_type = "NONE"
  labels                     = var.labels
  resource_policies          = var.resource_policies

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id

    access_config {
      nat_ip = var.nat_ip
    }
  }

  tags     = var.tags
  metadata = var.metadata

  scheduling {
    automatic_restart   = var.automatic_restart
    on_host_maintenance = var.on_host_maintenance
    preemptible         = var.preemptible
    provisioning_model  = var.provisioning_model
  }

  shielded_instance_config {
    enable_secure_boot = var.enable_secure_boot
    enable_vtpm        = var.enable_vtpm
  }

  lifecycle {
    ignore_changes = [service_account, description, metadata["ssh-keys"]]
  }
}
