module "vpc" {
  source = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/aws/vpc?ref=main"
  aws    = var.aws
  name   = "vpc"
  flags  = {
    is_mocking   = false
    is_ipam_used = true
  }
}

module "public-subnet" {
  source  = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/aws/subnet?ref=main"
  name    = "public-subnet"
  aws     = var.aws
  subnets = var.subnets
  vpc     = module.vpc.id
}

module "kafka" {
}

module "elasticsearch" {
}
