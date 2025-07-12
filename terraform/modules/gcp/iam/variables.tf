
variable "gcp" {
  description = "The gcp configuration for specific project"
  type        = object({
    service_account: string
    project_id:      string
    region:          string
    zone:            string
  })
}

variable "service_accounts" {
  description = "The list of service account which will be defined for specific project"
  type        = list(object({
    id:       string
    name:     string
    disabled: bool
  }))
  default     = []
}

variable "access_token" {
  description = "The google cloud platform access token which will be generated each time"
  type        = string
}
