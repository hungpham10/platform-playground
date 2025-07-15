terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.aws.region
  access_key = var.aws.access_key
  secret_key = var.aws.secret_key
}

locals {
}

resource "aws_subnet" "this" {
  count             = length(var.subnets)
  vpc_id            = var.vpc
  availability_zone = var.subnets[count.index].zone
  cidr_block        = var.subnets[count.index].cidr

  tags  = merge(
    { 
      "Name" = var.name,
      "Kind" = var.kind,
    },
    var.kind != "public" ? { "Environment" = var.environment } : {},
    var.tags,
    var.subnet_tags,
  )
}
