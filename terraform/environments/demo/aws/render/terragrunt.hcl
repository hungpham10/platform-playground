locals {
  configs  = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  projects = find_in_parent_folders("projects")
}

include "root" {
  path = "${get_repo_root()}/terraform/terragrunt.hcl"
}

inputs = {
  name = local.configs.locals.workspace
  aws  = local.configs.locals.aws
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
  subnets     = ${jsonencode(local.configs.locals.public_subnets)}
}

module "dev" {
  source      = "./specify"
  vpc         = module.common.vpc
  aws         = var.aws
  name        = "${local.configs.locals.workspace}"
  environment = "dev"
  subnets     = ${jsonencode(local.configs.locals.private_subnets["dev"])}
}

module "qc" {
  source      = "./specify"
  vpc         = module.common.vpc
  aws         = var.aws
  name        = "${local.configs.locals.workspace}"
  environment = "qc"
  subnets     = ${jsonencode(local.configs.locals.private_subnets["qc"])}
}

module "uat" {
  source      = "./specify"
  vpc         = module.common.vpc
  aws         = var.aws
  name        = "${local.configs.locals.workspace}"
  environment = "uat"
  subnets     = ${jsonencode(local.configs.locals.private_subnets["uat"])}
}
EOF
}

