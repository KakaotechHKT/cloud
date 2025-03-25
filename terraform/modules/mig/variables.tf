variable "name" {
  type = string
}

variable "instance_template" {
  type        = string
  description = "Prefix name for instance template"
}

variable "target_size" {
  type    = number
  default = 1
}

variable "region" {
  type = string
}

variable "ports" {
  type        = list(string)
  description = "List of ports to expose (used for health check)"
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "network_id" {
  type = string
}

variable "subnetwork_id" {
  type = string
}

variable "source_image" {
  description = "커스텀 GCE 이미지 경로"
  type        = string
}

variable "startup_script" {
  description = "Startup script to initialize the instance"
  type        = string
}

variable "min_replicas" {
  description = "오토스케일 최소 인스턴스 수"
  type        = number
}

variable "max_replicas" {
  description = "오토스케일 최대 인스턴스 수"
  type        = number
}

variable "target_cpu_utilization" {
  description = "CPU 사용률 기준"
  type        = number
}

variable "no_external_ip" {
  type    = bool
  default = false
}

variable "health_check_port" {
  type        = number
  description = "포트 헬스체크에 사용할 포트"
}

variable "port_name" {
  type    = string
  default = "http"
}