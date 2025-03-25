variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "network" {
  type = string
}

variable "tcp_established_idle_timeout_sec" {
  description = "TCP established connection idle timeout in seconds for Cloud NAT"
  type        = number
  default     = 1200 # 기본값은 GCP 기본값인 20분
}