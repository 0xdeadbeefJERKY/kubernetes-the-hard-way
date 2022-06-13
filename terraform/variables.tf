variable "project" {
  type = string
  description = "GCP project to which the infra will be deployed"
}

variable "region" {
  type = string
  description = "GCP region to which the infra will be deployed"
}

variable "zone" {
  type = string
  description = "GCP zone to which the infra will be deployed"
}

variable "subnet_cidr" {
  type = string
  default = "10.240.0.0/24"
  description = "IP range (CIDR) assigned to the subnet"
}

variable "num_controllers" {
  type = number
  default = 3
  description = "Number of Kubernetes controller compute instances"
}
