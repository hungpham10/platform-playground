variable "vpc" {
  type = string
}

variable "subnets" {
  type = list(object({
    cidr = string
    zone = string
  }))
}

variable "name" {
  type = string
}

variable "kind" {
  type    = string
  default = "public"
}

variable "environment" {
  type    = string
  default = ""
}

variable "aws" {
  description = "The AWS configuration"
  type        = object({
    region:     string
    access_key: string
    secret_key: string
  })
}
