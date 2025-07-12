terraform {
  required_version = ">= 1.0.0"
  required_providers {
    remote = {
      source  = "tenstad/remote"
      version = "0.1.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

locals {
  tls_key = {
    pubkey  = length(var.tls_key.pubkey) > 0 ? var.tls_key.pubkey : tls_private_key.k8s.public_key_openssh
    privkey = length(var.tls_key.privkey) > 0 ? var.tls_key.privkey : tls_private_key.k8s.private_key_openssh
  }

  kubeconfig_yaml_content = var.flags.enable_notify_when_done ? yamldecode(data.remote_file.get_master_kuberconfig[0].content) : null
}

resource "tls_private_key" "k8s" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "k8s-master" {
  source          = "../../node"
  topdir          = var.topdir
  node_type       = "master"
  format          = "k8s"
  vmid            = var.vmid
  partition       = var.partition
  total_partition = var.total_partition
  username        = var.username
  password        = var.password
  name            = var.name
  proxmox         = var.proxmox
  metric          = var.metric
  iothread        = var.iothread
  template        = var.template
  cpu             = var.cpus.master
  socket          = var.sockets
  memory          = var.memory.master
  disks           = var.disks.master
  telegram        = var.telegram
  vault           = var.vault
  networks        = var.networks
  netmask         = var.netmask
  gateway         = var.gateway
  promtail        = var.promtail
  debug           = var.debug
  bastion         = var.vtep.bastion
  flags = {
    enable_cloud_init       = true
    enable_notify_when_done = var.flags.enable_notify_when_done
    enable_elastic_network  = var.flags.enable_elastic_network
  }

  repository = var.repository
  branch     = var.branch
  playbook   = "playbooks/controller.yml"
  tls_key = {
    pubkey  = length(var.tls_key.pubkey) > 0 ? var.tls_key.pubkey : tls_private_key.k8s.public_key_openssh
    privkey = length(var.tls_key.privkey) > 0 ? var.tls_key.privkey : tls_private_key.k8s.private_key_openssh
  }

  instruction_folder        = var.instruction_folder
  infrastructure_config_map = var.infrastructure_config_map
}
