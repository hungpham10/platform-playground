locals {
  workspace      = "demo-aws"
  organization   = "hungpham10"

  // @NOTE: configure access token
  aws            = {
    region       = get_env("AWS_REGION", "us-west-2")
    access_key   = get_env("AWS_ACCESS_KEY")
    secret_key   = get_env("AWS_SECRET_KEY")
  }

  // @NOTE: configure network
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
  private_subnets = {
    "dev": [
      {
        cidr = "10.0.1.0/24"
        zone = "us-west-2b"
      },
    ]
    "qc": [
      {
        cidr = "10.0.2.0/24"
        zone = "us-west-2b"
      },
    ],
    "uat": [
      {
        cidr = "10.0.3.0/24"
        zone = "us-west-2b"
      },
    ],
  }
}

