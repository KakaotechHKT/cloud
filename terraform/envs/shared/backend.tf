terraform {
  backend "gcs" {
    bucket = "terraform-state-1q2w3e4r"
    prefix = "terraform/shared/terraform.tfstate"
  }
}