module "subnet-private" {
  source      = "git::ssh://git@github.com/hungpham10/platform-playground.git//terraform/modules/aws/subnet?ref=main"
  aws         = var.aws
  name        = var.name
  subnets     = var.subnets
  environment = var.environment
  vpc         = var.vpc
  kind        = "private"
}
