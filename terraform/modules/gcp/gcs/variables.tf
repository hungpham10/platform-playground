variable "configs" {
  default = []
}

variable "labels" {
  default = {}
}

variable "gcp" {
  description = "The gcp configuration for specific project"
  type        = object({
    service_account: string
    project_id:      string
    region:          string
    zone:            string
  })
}

variable "name" {
  description = ""
  type        = string
  default     = ""
}

variable "organization" {
  description = ""
  type        = string
  default     = ""
}

variable "access_token" {
  description = "The google cloud platform access token which will be generated each time"
  type        = string
}

variable "feature" {
  description = ""
  type        = string
}

variable "level" {
  description = ""
  type        = string
  default     = "dev"
}

variable "location" {
  description = ""
  type        = string
  default     = "Asia"
}

variable "flags" {
  description = ""
  type        = object({
    force_destroy: bool
    is_reuse_dns:  bool
  })
  default     = {
    force_destroy = true
    is_reuse_dns  = false
  }
}

variable "website" {
  description = ""
  type        = object({
    max_age: number
    origin:  string
  })
  default      = {
    max_age = 3600
    origin  = ""
  }
}

