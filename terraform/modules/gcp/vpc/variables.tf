variable "access_token" {
  description = "The google cloud platform access token which will be generated each time"
  type        = string
}

variable "is_mocking" {
  description = "This flag is used to configure whether or not this module will be used to mock with data of existence instances"
  type        = bool
  default     = false
}

variable "subnet" {
  description = "List subnet name which are used to fetch data"
  type        = object({
    publics:  list(string)
    privates: list(string)
  })
  default     = {
    publics  = []
    privates = []
  }
}

variable "auto_create_subnetworks" {
  description = "Flag to enable/disable auto create subnetwork if needs"
  type        = bool
  default     = true
}

variable "cidr_range" {
  description = "The range of CIDR network"
  type        = list(object({
    private: object({
      range:  string
      begin:  number
      end:    number
    })
    public: object({
      range:  string
      begin:  number
      end:    number
    })
  }))
  default    = [{
    private = {
      range  = "10.1.%d.0/24"
      begin  = 0
      end    = 0
    }
    public = {
      range  = "10.1.%d.0/24"
      begin  = 0
      end    = 0
    }
  }]
}

variable "name" {
  description = "The custom project name which is used when we share gcp project with another teams"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region in which this VPC will be located"
  type        = string
  default     = "asia-east1"
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

