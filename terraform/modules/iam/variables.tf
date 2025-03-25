variable "name" {
  type        = string
  description = "Service account name"
}

variable "display_name" {
  type        = string
  description = "Service account display name"
}

variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "roles" {
  type        = list(string)
  description = "List of IAM roles to attach"
}