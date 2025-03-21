variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the compute instance"
  type        = string
}

variable "zone" {
  description = "Zone for the compute instance"
  type        = string
}

variable "nat_ip" {
  description = "NAT IP address for the compute instance"
  type        = string
}

variable "network_id" {
  description = "Network ID"
  type        = string
}

variable "subnetwork_id" {
  description = "Subnetwork ID"
  type        = string
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
}

variable "boot_disk_size" {
  description = "Boot disk size (GB)"
  type        = number
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
}

variable "labels" {
  description = "Labels for the instance"
  type        = map(string)
  default     = {}
}

variable "resource_policies" {
  description = "Resource policies"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Instance tags"
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = "Instance metadata"
  type        = map(string)
  default     = {}
}

variable "automatic_restart" {
  description = "Automatic restart setting"
  type        = bool
  default     = true
}

variable "on_host_maintenance" {
  description = "On host maintenance setting"
  type        = string
  default     = "MIGRATE"
}

variable "preemptible" {
  description = "Preemptible instance setting"
  type        = bool
  default     = false
}

variable "provisioning_model" {
  description = "Provisioning model"
  type        = string
  default     = "STANDARD"
}

variable "enable_secure_boot" {
  description = "Enable secure boot"
  type        = bool
  default     = false
}

variable "enable_vtpm" {
  description = "Enable vTPM"
  type        = bool
  default     = true
}
