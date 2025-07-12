variable "aws" {
  description = "The AWS configuration"
  type        = object({
    region:     string
    access_key: string
    secret_key: string
  })
}
