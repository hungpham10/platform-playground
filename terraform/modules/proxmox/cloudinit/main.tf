terraform {
  required_version = ">= 1.0.0"
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.3"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

data "local_file" "bootloader_sh" {
  filename = "${path.module}/bootloader.sh"
}

//data "archive_file" "instruction_tar_gz" {
//  type        = "tar"
//  output_path = "${path.module}/instruction.tar.gz"
//
//  source {
//    content  = file("${var.instruction_folder}/agent")
//    filename = "agent"
//  }
//  source {
//    content  = file("${var.instruction_folder}/agent.db")
//    filename = "agent.db"
//  }
//  source {
//    content  = file("${var.instruction_folder}/agent.service")
//    filename = "agent.service"
//  }
//}

resource "tls_private_key" "internal" {
  count     = var.metric > 0 ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "cloud_init_user_data_file" {
  count   = var.metric
  content = sensitive(templatefile("${path.module}/cloudinit.cfg", {
    # @NOTE: common configuration
    fqdn               = "${var.format}-${var.node_type}-${var.name}-${count.index}"
    networks           = jsonencode(var.networks)
    disks              = jsonencode(var.disks)
    privkey            = base64encode(length(var.tls_key.privkey) == 0 ? tls_private_key.internal[0].private_key_openssh : var.tls_key.privkey)
    pubkey             = length(var.tls_key.pubkey) == 0 ? tls_private_key.internal[0].public_key_openssh : var.tls_key.pubkey
    username           = var.username
    telegram_bot_token = var.telegram.token
    telegram_chat_id   = var.telegram.chat_id

    # @NOTE: render bootloader script from our utilities, this will be used
    #        to boot our system
    bootloader_sh_content       = base64gzip(data.local_file.bootloader_sh.content)
    bootloader_arguments_in_str = join(
      " ",
      flatten([
        # @NOTE: control network type
        var.flags.use_elastic_network ? "" : format("--ip ${var.networks[0].ip_range}", var.networks[0].ip_beg + count.index),

        # @NOTE: configure installer node where we provide central configuration
        length(var.installer) > 0 ? format("--tftp_server_ip", var.installer) : "",

        # @NOTE: common configuration
        format("--debug"),
        format("--hostname %s", "${var.format}-${var.node_type}-${var.name}-${count.index}"),
        format("--playbook %s", "${var.playbook}"),
        format("--use_alpaca_agent %s", var.flags.use_agent ? "true" : "false"),

        # @NOTE: when done, notify status
        var.flags.use_notify_when_done ? [
          format("--telegram_chat_id %s", "${var.telegram.chat_id}"),
          format("--telegram_bot_token %s", "${var.telegram.token}"),
        ] : [],

        # @NOTE: specify configuration
        lookup(local.bootloader_arguments, var.node_type, local.bootloader_arguments["default"])
      ]),
    )

    # @NOTE: generate playbook.tar.gz as distributed version for dedicated clients
    access_token     = var.access_token
    project_id       = var.project_id
    tag              = var.tag
    artifact_host    = var.artifact_host
    artifact_project = var.artifact_project

    # @NOTE: generate infrastructure.yml directly from terraform, this happen when we try
    #        to build installer node
    inventory = base64gzip(jsonencode(var.inventory))

    # @NOTE: pass proxmox master to control where to access configuration
    proxmox_host     = var.proxmox.host
    proxmox_port     = var.proxmox.port
    proxmox_password = var.proxmox.password
  }))

  filename = "${path.module}/conf/user_data_${var.format}-${var.node_type}-${var.name}-${count.index}.cfg"
}

resource "null_resource" "cloud_init_config_files" {
  count = var.metric

  connection {
    type        = "ssh"
    user        = "root"
    host        = var.proxmox.host
    port        = var.proxmox.port
    password    = var.proxmox.password
    private_key = var.proxmox.private_key
  }

  provisioner "file" {
    source      = local_file.cloud_init_user_data_file[count.index].filename
    destination = "/var/lib/vz/snippets/user_data_${var.format}-${var.node_type}-${var.name}-${count.index}.yml"
  }
}
