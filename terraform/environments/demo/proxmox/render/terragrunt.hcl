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
variable "proxmox" {
  description = "The proxmox configuration"
  type = object({
    api : string
    host : string
    port : number
    node : string
    token : string
    timeout : number
    secret : string
    bridge : string
    password : string
    private_key : string
    cluster : object({
      size : number
      id : number
    })
  })
}

module "common" {
  source      = "./shared"
  proxmox     = var.proxmox
}
EOF
}

