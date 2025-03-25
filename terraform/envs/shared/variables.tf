variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-northeast3"
}

variable "credential_file_path" {
  description = "Local path to GCP credentials file"
  type        = string
  sensitive   = true
}