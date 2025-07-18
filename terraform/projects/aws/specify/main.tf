module "subnet-private" {
  source      = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/aws/subnet?ref=main"
  aws         = var.aws
  name        = var.name
  subnets     = var.subnets
  environment = var.environment
  vpc         = var.vpc
  kind        = "private"
}

module "vm" { 
  source = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/aws/vm?ref=main"
  aws    = var.aws
  name   = var.name
  subnet = module.subnet-private.id
  vpc    = var.vpc
}

module "s3" {
  source = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/aws/s3?ref=main"
  aws    = var.aws
  name   = var.name
  subnet = module.subnet-private.id
  vpc    = var.vpc
}

