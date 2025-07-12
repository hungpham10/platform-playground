provider "helm" {
  kubernetes = {
    host                   = var.kubernetes.host
    client_key             = var.kubernetes.client_key
    client_certificate     = var.kubernetes.client_certificate
    cluster_ca_certificate = var.kubernetes.cluster_ca_certificate
  }

  registries = [
    
  ]
}

provider "kubernetes" {

}
