variable "name" {
  description = "The custom project name which is used when we share gcp project with another teams"
  type        = string
}

variable "access_token" {
  description = "The google cloud platform access token which will be generated each time"
  type        = string
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

