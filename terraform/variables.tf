variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-northeast3"
}

variable "credential_file_path" {
  description = "Local path to GCP credentials file"
  type        = string
  sensitive   = true
}
