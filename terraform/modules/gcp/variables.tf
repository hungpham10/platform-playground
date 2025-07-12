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
  description = "The cluster name"
  type        = string
}

variable "cidr_range" {
  description = "The cidr range which will be used to configure network range ip for everything inside cluster"
  type        = object({
    instance: object({
      private: object({
        range: string
        begin: number
        end:   number
      })
      public:  object({
        range: string
        begin: number
        end:   number
      })
    })
    kubernetes: object({
      private: object({
        range: string
        begin: number
        end:   number
      })
      public:  object({
        range: string
        begin: number
        end:   number
      })
    })
  })
  default     = {
    instance = {
      private = {
        range  = "10.1.%d.0/24"
        begin  = 0
        end    = 1
      }
      public = {
        range  = "10.1.%d.0/24"
        begin  = 0
        end    = 0
      }
    }
    kubernetes = {
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
    }
  }
}

variable "ip_range" {
  type        = object({
    instance: list(object({
      format: string
      begin:  number
      end:    number
    }))
    kubernetes: list(object({
      format: string
      begin:  number
      end:    number
    }))
  })
  default     = {
    instance   = [{
      format     = "10.1.0.%d"
      begin      = 2
      end        = 3
    }]
    kubernetes = [{
      format     = "10.1.0.%d"
      begin      = 2
      end        = 10
    }]
  }
}

variable "status" {
  type    = object({
    instance:   bool
    kubernetes: bool
  })
  default = {
    instance   = true
    kubernetes = true
  }
}
