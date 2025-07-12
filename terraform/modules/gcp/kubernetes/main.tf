terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.14.0"
    }
  }
}

provider "kubernetes" {
  host  = "https://${var.endpoint}"
  token = var.access_token
  cluster_ca_certificate = base64decode(
    var.cluster_ca_certificate,
  )
}

