module "vpc" {
  source = "../../../modules/aws/vpc"
  aws    = var.aws
  name   = "vpc"
  flags  = {
    is_mocking   = false
    is_ipam_used = true
  }
}

module "public-subnet" {
  source  = "../../../modules/aws/subnet"
  aws     = var.aws
  name    = "public"
  subnets = var.subnets
}
