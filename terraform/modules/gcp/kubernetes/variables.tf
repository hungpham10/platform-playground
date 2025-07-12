variable "timeout" {
  description = "The helm process's timeout in seconds"
  type        = number
  default     = 300
}

variable "access_token" {
  description = "The google cloud platform access token which will be generated each time"
  type        = string
}

variable "endpoint" {
  description = "The GKE endpoint which will be used to pass directly to another module"
  type        = string
}

variable "cluster_name" {
  description = "The location where the cluster has been setup"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The GKE cluster CA certificate"
  type        = string
}
