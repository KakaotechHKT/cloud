variable "network_name" {
  description = "Name of the network"
  type        = string
  default     = "default"
}

variable "subnetwork_name" {
  description = "Name of the subnetwork"
  type        = string
  default     = "default"
}

variable "region" {
  description = "Region for the subnetwork"
  type        = string
}
