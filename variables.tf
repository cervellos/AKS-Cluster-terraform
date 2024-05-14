variable "location" {
  description = "location of resources"
  default     = "eastus"
  type        = string
}

variable "prefix" {
  description = "name project"
  default     = "mmrv"
  type        = string
}

variable "environment" {
  description = "ej. dev staging prod"
  default     = "staging"
  type        = string
}
/*
variable "aks_service_principal_app_id" {
  description = "service principal id"
  type        = string
}

variable "aks_service_principal_client_secret" {
  description = "service principal secret"
  type        = string
}

variable "aks_service_principal_object_id" {
  description = "service principal object id"
  type        = string
}*/

variable "aks_service_cidr" {
  description = "CIDR notation IP range from which to assign service cluster IPs"
  default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "DNS server IP address"
  default     = "10.0.0.10"
}

variable "username" {
  description = "admin use for node instances"
  default     = "aks-admin"
}

