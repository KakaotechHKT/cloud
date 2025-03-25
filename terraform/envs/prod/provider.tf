provider "google" {
  project = var.project
  region  = var.region

  # CI 환경에서는 환경변수 GOOGLE_APPLICATION_CREDENTIALS 사용
  credentials = can(var.credential_file_path) && length(var.credential_file_path) > 0 ? file(var.credential_file_path) : null
}

terraform {
  required_version = ">= 1.0"

  # 원하는 경우, 백엔드(예: remote backend, GCS 등) 설정도 여기서 가능
  # backend "gcs" {
  #   bucket = "my-terraform-state-bucket"
  #   prefix = "some-prefix"
  # }
}
