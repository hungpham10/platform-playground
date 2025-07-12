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

data "aws_region" "current" {}

data "aws_vpc" "this" {
  count = var.flags.is_mocking ? 1 : 0
}

resource "aws_vpc_ipam" "this" {
  operating_regions {
    region_name = data.aws_region.current.region
  }

  count = !var.flags.is_mocking && var.flags.is_ipam_used ? 1 : 0
  tags  = merge(
    { "Name" = var.name },
    var.tags,
    var.vpc_tags,
  )
}

resource "aws_vpc_ipam_pool" "this" {
  count          = !var.flags.is_mocking && var.flags.is_ipam_used ? 1 : 0
  locale         = data.aws_region.current.region
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.this[0].private_default_scope_id
  tags           = merge(
    { "Name" = var.name },
    var.tags,
    var.vpc_tags,
  )
}

resource "aws_vpc" "this" {
  count      = var.flags.is_mocking ? 0 : 1
  cidr_block = var.flags.is_ipam_used ? null : var.cidr[0]

  ipv4_ipam_pool_id   = var.flags.is_ipam_used ? aws_vpc_ipam_pool.this[0].id : null
  ipv4_netmask_length = var.ipam.netmask

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.vpc_tags,
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count      = var.flags.is_mocking ? 0 : (length(var.cidr) >= 1 ? length(var.cidr) - 1 : 0)
  vpc_id     = var.flags.is_mocking ? data.aws_vpc.this[0].id : aws_vpc.this[0].id
  cidr_block = var.cidr[count.index + 1]
}

