locals {
  configs  = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  projects = find_in_parent_folders("projects")
}

include "root" {
  path = "${get_repo_root()}/terraform/terragrunt.hcl"
}

inputs = {
  name    = local.configs.locals.workspace
  proxmox = local.configs.locals.proxmox
}

terraform {
  source = "${get_repo_root()}/terraform/projects//bli"

  extra_arguments "terragrunt_generated_vars" {
    commands = "${get_terraform_commands_that_need_vars()}"
  }
}

generate "main" {
  path              = "main.tf"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<EOF
module "common" {
  source          = "./shared"
  bastion         = "" 
  name            = ${jsonencode(local.configs.locals.workspace)}
  vmid            = ${jsonencode(local.configs.locals.vmid)}
  total_partition = ${jsonencode(local.configs.locals.total_partition)}
  proxmox         = ${jsonencode(local.configs.locals.proxmox)}
  internet        = ${jsonencode(local.configs.locals.internet)}
  internal        = ${jsonencode(local.configs.locals.internal)}
  gateway         = ${jsonencode(local.configs.locals.gateway)}
  postgres        = ${jsonencode(local.configs.locals.postgres)}
}

output "postgres" {
  value = module.common.postgres
}

output "gateway" {
  value = module.common.gateway
}
EOF
}

