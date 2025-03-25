provider "google" {
  project     = var.project
  region      = var.region
  credentials = (
    length(var.credential_file_path) > 0 ? file(var.credential_file_path) : null
  )
}

terraform {
  required_version = ">= 1.0"

  # 원하는 경우, 백엔드(예: remote backend, GCS 등) 설정도 여기서 가능
  # backend "gcs" {
  #   bucket = "my-terraform-state-bucket"
  #   prefix = "some-prefix"
  # }
}
