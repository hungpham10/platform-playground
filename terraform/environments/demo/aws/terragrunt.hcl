locals {
  workspace      = "demo-aws"
  organization   = "hungpham10"
  projects       = find_in_parent_folders("projects")
  aws            = {
    region       = get_env("AWS_REGION", "us-west-2")
    access_key   = get_env("AWS_ACCESS_KEY")
    secret_key   = get_env("AWS_SECRET_KEY")
  }
  public_cidr    = "10.0.0.0/24"
  public_subnets = [
    {
      cidr = cidrsubnet(local.public_cidr, 2, 0)
      zone = "us-west-2a"
    },
    {
      cidr = cidrsubnet(local.public_cidr, 2, 1)
      zone = "us-west-2b"
    },
    {
      cidr = cidrsubnet(local.public_cidr, 2, 2)
      zone = "us-west-2c"
    }
  ]

  main_tf = <<EOF
variable "aws" {
  description = "The AWS configuration"
  type        = object({
    region:     string
    access_key: string
    secret_key: string
  })
}

module "common" {
  source      = "./shared"
  aws         = var.aws
  subnets     = ${jsonencode(local.public_subnets)}
}
EOF
}

