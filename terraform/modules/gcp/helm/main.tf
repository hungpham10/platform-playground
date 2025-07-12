terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.7.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.14.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host  = "https://${var.endpoint}"
    token = var.access_token
    cluster_ca_certificate = base64decode(
      var.cluster_ca_certificate,
    )
  }
}

provider "kubernetes" {
  host  = "https://${var.endpoint}"
  token = var.access_token
  cluster_ca_certificate = base64decode(
    var.cluster_ca_certificate,
  )
}

resource "kubernetes_namespace" "namespace" {
  for_each = { for item in var.configs: item.name => item }

  metadata {
    name = each.value.namespace
  }

  depends_on = [var.dependencies]
}

resource "helm_release" "helm" {
  for_each   = { for item in var.configs: item.name => item }

  name       = each.value.name
  lint       = true
  chart      = each.value.chart
  version    = each.value.version
  timeout    = var.timeout
  namespace  = each.value.namespace
  repository = each.value.repository

  dynamic "set" {
    for_each = { for item in each.value.values: item.name => item }

    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  depends_on = [
    kubernetes_namespace.namespace
  ]
}
