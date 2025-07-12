locals {
  platform        = read_terragrunt_config(
    "${get_terragrunt_dir()}/../terragrunt.hcl"
  )
  private_subnets = [
    {
      cidr = "10.0.1.0/24"
      zone = "us-west-2a"
    },
    {
      cidr = "10.0.2.0/24"
      zone = "us-west-2b"
    },
    {
      cidr = "10.0.3.0/24"
      zone = "us-west-2c"
    }
  ]
}

include "root" {
  path = "${get_repo_root()}/terraform/terragrunt.hcl"
}

terraform {
  source = "${get_repo_root()}/terraform/projects//aws"

  extra_arguments "terragrunt_generated_vars" {
    commands = "${get_terraform_commands_that_need_vars()}"
  }
}

generate "main" {
  path              = "main.tf"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<EOF
${local.platform.locals.main_tf}

module "dev" {
  source      = "./specify"
  vpc         = module.common.vpc
  aws         = var.aws
  name        = var.name
  environment = "dev"
  subnets     = ${jsonencode(local.private_subnets)}
}
EOF
}

inputs = {
  name = "demo"
  aws  = local.platform.locals.aws
}
