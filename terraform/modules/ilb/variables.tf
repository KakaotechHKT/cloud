variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "service_port" {
  type = number
}

variable "instance_group" {
  type = string
}

variable "port_name" {
  type    = string
  default = "http"
}