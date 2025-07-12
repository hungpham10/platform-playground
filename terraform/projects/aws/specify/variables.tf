
variable "aws" {
  description = "The AWS configuration"
  type        = object({
    region:     string
    access_key: string
    secret_key: string
  })
}

variable "name" {
  type = string
}

variable "vpc" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnets" {
  type = list(object({
    cidr = string
    zone = string
  }))
}
