output "ip_list" {
  description = "The list of IP addresses which are created after nodes have been promoted"
  value = [
    for i in range(var.metric) : format(var.networks[0].ip_range, var.networks[0].ip_beg + i)
  ]
}
