variable "firewall_name" {
  description = "Name of the firewall rule"
  type        = string
}

variable "network_id" {
  description = "Network ID"
  type        = string
}

variable "priority" {
  description = "Priority for the firewall rule"
  type        = number
  default     = 1000
}

variable "direction" {
  description = "Direction of traffic for the firewall rule"
  type        = string
  default     = "INGRESS"
}

variable "description" {
  description = "Description for the firewall rule"
  type        = string
  default     = ""
}

variable "allow" {
  description = "List of maps with allow rule details"
  type        = list(object({
    protocol = string
    ports    = list(string)
  }))
}

variable "source_ranges" {
  description = "Source ranges"
  type        = list(string)
}

variable "source_tags" {
  description = "Source tags"
  type        = list(string)
}

variable "target_tags" {
  description = "Target tags"
  type        = list(string)
}
