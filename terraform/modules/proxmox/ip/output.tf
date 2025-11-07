output "ip_list" {
  description = "The list of IP addresses which are created after nodes have been promoted"
  value       = local.ip_list
}

output "ip_with_netmask_list" {
  description = "The list of IP addresses which are created after nodes have been promoted"
  value       = [
    for i in range(0, length(var.networks)): flatten([
      for ip in local.ip_list[i]: [
        "${ip}/${var.netmask}"
      ]
    ])
  ]
}

output "netmask" {
  description = "The netmask"
  value       = var.netmask
}

output "ipconfigs" {
  description = "The list of config ip which will be used to start proxmox nodes"
  value       = local.ipconfigs
}

output "network" {
  description = "The network definition for Ansible"
  value       = [
    for j in range(0, length(var.networks)): flatten([
      for i in range(0, var.metric): [
        {
          name        = var.networks[j].iface
          gateway     = var.networks[j].gateway
          nameservers = var.networks[j].namespaces
          addresses   = [
            local.ip_list[j][i]
          ]
          dhcp        = false
          type        = "ethernet"
        }
      ]
    ])
  ]
}
