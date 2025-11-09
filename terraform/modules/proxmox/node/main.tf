terraform {
  required_version = ">= 1.0.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.8.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.49.2"
    }
    hcp = {
      source = "hashicorp/hcp"
      version = "0.91.0"
    }
  }
}

provider "tfe" {
  token = var.tfe.token
}

provider "proxmox" {
  pm_tls_insecure = true

  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }

  pm_timeout          = var.proxmox.timeout
  pm_api_url          = var.proxmox.api
  pm_api_token_id     = var.proxmox.token
  pm_api_token_secret = var.proxmox.secret
}

locals {
  max_number_of_node = var.networks[0].ip_end - var.networks[0].ip_beg
  metric             = min(var.metric, local.max_number_of_node)
  need_waiting       = !var.flags.use_elastic_network && var.flags.use_notify_when_done
}

module "env" {
  source = "../env"
}

module "ip" {
  source   = "../ip"
  metric   = local.metric
  networks = var.networks
  netmask  = var.netmask
  proxmox  = var.proxmox
}

# Setup cloudinit configuration
module "cloudinit" {
  source       = "../cloudinit"
  name         = var.name
  topdir       = var.topdir
  node_type    = var.node_type
  metric       = var.metric
  tls_key      = var.tls_key
  proxmox      = var.proxmox
  disks        = var.disks
  networks     = var.networks 
  playbook     = var.playbook
  flags        = {
    use_elastic_network = var.flags.use_elastic_network
    use_notify_when_done = var.flags.use_notify_when_done
    use_statefulset_strategy = var.flags.use_statefulset_strategy
    use_agent = false
  }

  # @NOTE: serving only for admin to manage each instance in Alpaca cloud
  username     = module.env.username
  telegram     = module.env.telegram
  promtail     = module.env.promtail

  # @NOTE: provided by release engineer to each client
  access_token = module.env.access_token
  tag          = module.env.tag
}

# Deploy a new node using proxmox
resource "proxmox_vm_qemu" "node" {
  count = floor(local.metric / var.proxmox.cluster.size) + (local.metric % var.proxmox.cluster.size > var.proxmox.cluster.id ? 1 : 0)
  name  = "${var.format}-${var.node_type}-${var.name}-${(count.index * var.proxmox.cluster.size + var.proxmox.cluster.id) + 1}"
  desc  = "A node with specify provided cloudinit inside"

  # We will shard the vmid into multiple partition so we could create multiple node
  # in parallel without handling dependencies
  vmid = var.vmid + (count.index * var.proxmox.cluster.size + var.proxmox.cluster.id + var.layer) * var.total_partition + var.partition

  # Node name has to be the same name as within the cluster
  # this might not include the FQDN
  target_node = var.proxmox.node

  # The template name to clone this vm from templates
  clone      = var.template
  full_clone = false

  # Activate QEMU agent for this VM
  agent = 1

  os_type = "cloud-init"
  cores   = var.cpu
  sockets = var.socket
  vcpus   = var.cpu
  cpu     = var.cpu_mode
  memory  = var.memory
  scsihw  = "virtio-scsi-pci"

  # Setup display
  vga {
    type = "cirrus"

    #Between 4 and 512, ignored if type is defined to serial
    memory = 4
  }

  # Setup the disk
  dynamic "disk" {
    for_each = var.disks

    content {
      size     = disk.value.size
      type     = "virtio"
      storage  = disk.value.pool
      iothread = var.iothread
      discard  = "on"

      # Advance disk configuration
      mbps        = var.opts.disk.mbps
      mbps_rd     = var.opts.disk.mbps_rd
      mbps_wr     = var.opts.disk.mbps_wr
      mbps_rd_max = var.opts.disk.mbps_rd_max
      mbps_wr_max = var.opts.disk.mbps_wr_max
    }
  }

  dynamic "network" {
    for_each = var.networks

    content {
      model  = "virtio"
      bridge = network.value.bridge
    }
  }

  # Serial interface of type socket is used by xterm.js
  # You will need to configure your guest system before being able to use it
  serial {
    id   = 0
    type = "socket"
  }

  # Setup cloud-init account
  ciuser     = module.env.username
  cipassword = module.env.password

  # Setup the ip address using cloud-init.
  # Keep in mind to use the CIDR notation for the ip.
  ipconfig0 = var.flags.use_elastic_network ? "ip=dhcp" : module.ip.ipconfigs[count.index * var.proxmox.cluster.size + var.proxmox.cluster.id][0]

  # Custom proxmox node by using cloud-init
  cicustom = module.cloudinit.vendor[count.index * var.proxmox.cluster.size + var.proxmox.cluster.id]

  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply
  lifecycle {
    ignore_changes = [
      network,
      disk
    ]
  }
}

resource "null_resource" "wait_for_finishing_installing_instances" {
  depends_on = [proxmox_vm_qemu.node]
  count      = local.need_waiting ? 1 : 0

  connection {
    type        = "ssh"
    user        = module.env.username
    host        = length(var.bastion) > 0 ? var.bastion : format(var.networks[0].ip_range, var.networks[0].ip_beg + count.index)
    private_key = module.cloudinit.private_key
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      join("", [
        length(var.bastion) > 0 ? "ssh -vvvv -o StrictHostKeyChecking=no -i /etc/ansible/id_rsa ${module.env.username}@${format(var.networks[0].ip_range, var.networks[0].ip_beg + count.index)} " : "",
        "cloud-init status --wait"
      ]),
    ]
  }
}
