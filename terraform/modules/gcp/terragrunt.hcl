locals {
  admin_vars  = read_terragrunt_config("${get_repo_root()}/infrastructure/sre.hcl")
  debug       = local.admin_vars.locals.debug
  gateway_id  = 1
  cidr_format = "10.124.5.%d"

  new_vpc_module = <<-EOF
module "vpc" {
  source       = "./vpc"
  gcp          = var.gcp
  name         = var.name
  access_token = module.access-token.token
  cidr_range   = [var.cidr_range.instance, var.cidr_range.kubernetes]
}
EOF

  reuse_vpc_module = <<-EOF
variable "vpc_name" {
  description = "The vpc name which we would like to use"
  type        = string
}

module "vpc" {
  source       = "./vpc"
  gcp          = var.gcp
  name         = length(var.vpc_name) > 0? var.vpc_name :var.name
  is_mocking   = true
  access_token = module.access-token.token
}
EOF

  reuse_instance_module = <<-EOF
module "instance" {
  source       = "./instance"
  name         = var.name
  gcp          = var.gcp
  access_token = module.access-token.token
  zone         = format("%s-%s", var.gcp.region, var.gcp.zone)
  network      = module.vpc.network[0]
  subnetwork   = module.vpc.subnetwork
  status       = var.status.instance
  ip_range     = var.ip_range.instance
}
EOF

  new_instance_module = <<-EOF
variable "min_cpu_platform" {
  description = "The node type which is pointing out which kind of component we ought to be installing on this"
  type        = string
  default     = "generic"
}

variable "boot_snapshot" {
  description = "The snapshot which is used to deploy new instance's boot disk"
  type        = string
  default     = ""
}

variable "flags" {
  description = "The flags which are used"
  type        = string
  default     = "generic"
}

module "instance" {
  source           = "./instance"
  name             = var.name
  gcp              = var.gcp
  is_mocking       = false
  access_token     = module.access-token.token
  zone             = format("%s-%s", var.gcp.region, var.gcp.zone)
  network          = module.vpc.network[0]
  subnetwork       = module.vpc.subnetwork
  status           = var.status.instance
  ip_range         = var.ip_range.instance
  min_cpu_platform = var.min_cpu_platform

  # @NOTE: update flags
  preemptible               = true //var.flags.enable_preemptible
  allow_stopping_for_update = true //var.flags.enable_stopping_for_update

  # @NOTE: update external flags
  flags = {
    enable_iap_tunnel = true //var.flags.enable_iap_tunnel
  }

  # @NOTE: update policy
  //is_immutable = var.policies.immutable
  //maintenance  = var.policies.maintenance
  //provisioning = var.policies.provisioning

  # @NOTE: everything about service account who can access instances
  //service_accounts = var.access.services
  //members          = var.access.members
  //groups           = var.access.groups

  # @NOTE: define disk for instances
  boot_disk = {
    image       = "centos-6-v20180104"
    size        = 10
    source      = var.boot_snapshot
    auto_delete = true
    mode        = "READ_WRITE"
    name        = "default"
  }
}
EOF

  gke_module = <<-EOF
variable "node_version" {
  description = "The kubernetes version"
  type        = string
}

module "kubernetes" {
  source       = "./gke"
  name         = var.name
  gcp          = var.gcp
  access_token = module.access-token.token
  network      = module.vpc.network[0]
  node_version = var.node_version
  subnetwork   = module.vpc.subnetwork[0]
}
EOF

  disk_module = <<-EOF
module "disks" {
}
EOF

  api_gateway_module = <<-EOF
module "api-gateway" {
  source       = "./api-gateway"
  name         = var.name
  gcp          = var.gcp
  access_token = module.access-token.token
}
EOF

  non_renderable_website_reuse_dns_module = <<-EOF
module "website-gcs" {
  source       = "./gcs"
  feature      = "website"
  name         = var.name
  gcp          = var.gcp
  access_token = module.access-token.token
}
EOF
  non_renderable_website_module = <<-EOF
variable "organization" {
  description = "The organization name"
  type        = string
}

module "website-gcs" {
  source       = "./gcs"
  feature      = "website"
  name         = var.name
  gcp          = var.gcp
  organization = var.organization
  access_token = module.access-token.token
}
EOF

  helm_install_ingress_module = <<-EOF
variable "nginx" {
  type = object({
    name:      string
    version:   string
    namespace: string
  })
}

locals {
  nginx_ingress_helm = [{
    chart      = "ingress-nginx"
    name       = var.nginx.name
    version    = var.nginx.version
    namespace  = var.nginx.namespace
    repository = "https://kubernetes.github.io/ingress-nginx"
    values     = []
  }]
}

module "ingress-helm" {
  source                 = "./helm"
  endpoint               = module.kubernetes.endpoint
  access_token           = module.access-token.token
  cluster_name           = module.kubernetes.cluster_name
  cluster_ca_certificate = module.kubernetes.cluster_ca_certificate
  configs                = local.nginx_ingress_helm
  dependencies           = [
    module.kubernetes,
    module.vpc,
  ]
}
EOF
}
