variable "name" {
  description = "The service name which defines the common name of instances which serving this service"
  type        = string
}

variable "node_type" {
  description = "The node type which will be used to filter out in admin control about which kind of machine"
  type        = string
}

variable "metric" {
  description = "The number of instance for serving this service"
  type        = number
}

variable "role" {
  description = "The ansible role"
  type        = string
}

variable "net" {
  description = "The ansible password"
  type        = string
}

variable "interfaces" {
  description = "The network definition"
  type        = list(list(object({
    name        = string
    gateway     = string
    nameservers = list(string)
    addresses   = list(string)
    dhcp        = bool
    type        = string
  })))
}

variable "variables" {
  description = "List of variables"
  default     = {}
}
