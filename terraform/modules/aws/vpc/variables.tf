variable "aws" {
  description = "The AWS configuration"
  type        = object({
    region:     string
    access_key: string
    secret_key: string
  })
}

variable "cidr" {
  description = "The CIDR of this VPC"
  type        = list(string)
  default     = [
    "10.0.0.0/16"
  ]
}

variable "flags" {
  description = "Point out in which the resource is reused or not"
  type        = object({
    is_mocking:   bool
    is_ipam_used: bool
  })
  default     = {
    is_mocking   = false
    is_ipam_used = true
  }
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "ipam" {
  description = "IPAM configuration"
  type        = object({
    netmask: number
  })
  default     = {
    netmask = 24
  }
}
