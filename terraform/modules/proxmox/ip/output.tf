output "ip_list" {
  description = "The list of IP addresses which are created after nodes have been promoted"
  value       = local.ip_list
}

output "ip_with_netmask_list" {
  description = "The list of IP addresses which are created after nodes have been promoted"
  value       = local.ip_with_netmask_list[0]
}

output "netmask" {
  description = "The netmask"
  value       = var.netmask
}

output "ipconfigs" {
  description = "The list of config ip which will be used to start proxmox nodes"
  value       = local.ipconfigs
}

output "interfaces" {
  description = "The network definition for Ansible"
  value       = local.interfaces
}

output "networks" {
  description = "The network definition for Terraform"
  value       = var.networks
}
