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
  description = "The custom project name which is used when we share gcp project with another teams"
  type        = string
  default     = ""
}

variable "take_snapshots" {
  description = "Take new snapshot for current disks"
  type        = bool
  default     = false
}

variable "access_token" {
  description = "The google cloud platform access token which will be generated each time"
  type        = string
}

variable "metric" {
  description = "The number of disk will be created but don't want to attach to instances. This one is conflict directly with `instances`"
  type        = number
  default     = 0
}

variable "instances" {
  description = "The instances which will link 1 vs 1 with each disk"
  type = list(string)
  default = []
}

variable "disks" {
  description = "The existence disks which will be used as data provider for taking snapshot"
  type        = list(string)
  default     = []
}

variable "zone" {
  description = "The zone where to locate the disks"
  type        = string
  default     = "asia-east1-b"
}

variable "type" {
  description = "The disk type which will be used to specify some extra properties"
  type        = string
  default     = "pd-standard"
}

variable "size" {
  description = "The disk size, specify in GB only"
  type        = number
  default     = 1
}

variable "image" {
  description = "The base image"
  type        = string
  default     = ""
}

variable "snapshot" {
  description = "The snapshot, which will be used as base for this image"
  type        = string
  default     = ""
}

variable "snapshots" {
  description = "The list of snapshot, which will be used as base for this image for each disk"
  type        = list(string)
  default     = []
}

variable "opt" {
  description = "The advance configuration which will be used modify lowlevel properties of disk"
  type        = object({
    physical_block_size_bytes: number
    provisioned_iops:          number
  })
  default     = {
    physical_block_size_bytes = 4096
    provisioned_iops          = 0
  }
}
