# Overview
This is my journey when i switch from backend to SRE

# How-to setup
- Install infracost, terraform, terragrunt first
- Configure new account in app.terraform.io. This will be used to define organization in each environment
- Login to app.terraform.io using terraform
- Move to leaf folder in terraform/environment, for example terraform/environment/aws/dev, and perform terragrunt plan or terragrunt apply
- Please notice in some module, we must define environment variables, please configure it on app.terragrunt.io first
