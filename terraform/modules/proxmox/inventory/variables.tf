variable "username" {
  description = "The ansible username"
  type        = string
}

variable "password" {
  description = "The ansible password"
  type        = string
}

variable "role" {
  description = "The ansible role"
  type        = string
}

variable "net" {
  description = "The ansible password"
  type        = string
}

variable "instances" {
  description = "List of instance of this inventory"
  type        = list(string)
}

variable "networks" {
  description = "The network definition"
  type        = list(object({
    name        = string
    gateway     = string
    nameservers = list(string)
    addresses   = list(string)
    dhcp        = bool
    type        = string
  }))
}

variable "variables" {
  description = "List of variables"
  default     = {}
}
