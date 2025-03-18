provider "google" {
  project     = "potent-result-454023-m7"
  region      = "asia-northeast3"
  credentials = file(var.credential_file_path)
}

data "google_project" "existing_project" {
  project_id = "potent-result-454023-m7"
}

data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_subnetwork" "default" {
  name   = "default"
  region = "asia-northeast3"
}
