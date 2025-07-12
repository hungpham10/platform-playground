locals {
  workspace_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))

  # @NOTE: extract organization variables
  organization = local.workspace_vars.locals.organization
  workspace    = local.workspace_vars.locals.workspace
}

generate "remote_state" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "remote" {
    organization = "${local.organization}"

    workspaces {
      name = "${local.workspace}"
    }
  }
}
EOF
}

terraform {
  before_hook "clean" {
    commands = ["plan"]
    execute  = ["rm", "-fr", "./terragrunt.hcl"]
  }

  after_hook "run_infracost" {
    commands = ["plan"]
    execute  = ["infracost", "breakdown", "--path", "."]
  }
}
