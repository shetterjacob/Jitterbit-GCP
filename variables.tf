variable "project_id" {
  type           = string
  description    = "Project ID for intended working environment"
  default        = "vibrant-fabric-286015"
}

variable "region" {
  type           = string
  description    = "Region for this infrastructure"
  default        = "us-central1"
}

variable "zone" {
  type           = string
  description    = "Zone for this infrastructure"
  default        = "us-central1-a"
}

variable "name" {
  type           = string
  description    = "Name for this infrastructure"
  default        = "jitterbit"
}

variable "ip_cidr_range" {
  type           =string
  description    ="List of The range of internal addresses that are owned by this subnetwork."
  default        ="10.16.128.0/24"
}

variable "vm_type" {
  type           = string
  description    ="Type of VM to be used in Compute creation."
  default        ="n2-highcpu-8"
}
