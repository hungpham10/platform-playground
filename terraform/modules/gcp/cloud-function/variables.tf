variable "name" {
  description = "The naming of this function"
  type        = string
}

variable "ticket" {
  description = "The ticket which refereal with this function"
  type        = string
}

variable "bucket" {
  description = "The bucket which is refered to where to store the source code"
  type        = string
}

variable "archive" {
  description = "The archive file which compresses the whole source code"
  type        = string
}

variable "invokers" {
  description = "The archive file which compresses the whole source code"
  type        = list(string)
  default     = [
    "allUsers"
  ]
}

variable "description" {
  description = "The description which explans what will be doing for this function"
  type        = string
  default     = ""
}

