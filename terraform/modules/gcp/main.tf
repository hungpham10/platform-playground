locals {
  test = false
}

module "access-token" {
  source = "./token"
  gcp    = var.gcp
}

module "demo-vpc" {
  source       = "./vpc"
  gcp          = var.gcp
  is_mocking   = true
  name         = "default"
  access_token = module.access-token.token
  cidr_range   = [var.cidr_range.instance, var.cidr_range.kubernetes]
}

#module "demo-vm" {
#  source       = "./instance"
#  name         = "hungpham"
#  gcp          = var.gcp
#  access_token = module.access-token.token
#  zone         = "asia-east1-b"
#  network      = module.demo-vpc.network[0].name
#  subnetwork   = module.demo-vpc.subnetwork
#  status       = var.status.instance
#  ip_range     = var.ip_range.instance
#}
#
#module "demo-disk" {
#  source       = "./disk"
#  gcp          = var.gcp
#  name         = "hungpham"
#  access_token = module.access-token.token
#  instances    = module.demo-vm.id
#  size         = 30
#}

module "demo-gke" {
  source       = "./gke"
  name         = "hungpham"
  gcp          = var.gcp
  access_token = module.access-token.token
  network      = module.demo-vpc.network[0]
  subnetwork   = module.demo-vpc.subnetwork[0]
}

#module "kubernetes" {
#  source  = "./kubernetes"
#  timeout                = 1800
#  access_token           = module.access-token.token
#  endpoint               = module.demo-gke.endpoint
#  cluster_name           = module.demo-gke.cluster_name
#  cluster_ca_certificate = module.demo-gke.cluster_ca_certificate
#}

module "helm" {
  source  = "./helm"
  timeout                = 1800
  access_token           = module.access-token.token
  endpoint               = module.demo-gke.endpoint
  cluster_name           = module.demo-gke.cluster_name
  cluster_ca_certificate = module.demo-gke.cluster_ca_certificate
  configs                = [
  {
    name       = "superset"
    chart      = "superset/superset"
    namespace  = "superset"
    repository = "https://apache.github.io/superset"
    values     = [{
      name  = "global.postgresql.auth.postgresPassword"
      value = "123456"
    }]
  }]
}

//module "fetch-vpc" {
//  source       = "./vpc"
//  gcp          = var.gcp
//  access_token = module.access-token.token
//  is_mocking   = true
//  name         = "default"
//  subnet       = {
//    publics  = [
//      "default"
//    ]
//    privates = []
//  }
//}
//
//module "fetch-vm" {
//  source  = "./instance"
//  gcp          = var.gcp
//  name         = "hungpham"
//  is_mocking   = true
//  access_token = module.access-token.token
//  configs = [{
//    name = "hadn"
//    zone = "asia-east1-b"
//  }, 
//  {
//    name = "sonpn8-dev"
//    zone = "asia-east1-b"
//  }]
//}
//
//module "fetch-disk" {
//  source       = "./disk"
//  disks        = [
//    "hadn"
//  ]
//  gcp          = var.gcp
//  access_token = module.access-token.token
//}
//
//output "debug" {
//  value = module.fetch-vpc.subnetwork
//}

