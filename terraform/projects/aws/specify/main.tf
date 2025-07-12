module "subnet-private" {
  source      = "../../../modules/aws/subnet"
  aws         = var.aws
  name        = var.name
  subnets     = var.subnets
  environment = var.environment
  vpc         = var.vpc
  kind        = "private"
}
