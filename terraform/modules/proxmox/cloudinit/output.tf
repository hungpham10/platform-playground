output "vendor" {
  description = "The vendor uri which point to specific cloud init configuration files"
  value = [
    for i in range(var.metric) :
    format("user=local:snippets/user_data_%s-%s-%s-%d.yml", var.format, var.node_type, var.name, i)
  ]
}

output "private_key" {
  value = length(var.tls_key.privkey) == 0 ? tls_private_key.internal[0].private_key_openssh : var.tls_key.privkey
}

output "public_key" {
  value = length(var.tls_key.pubkey) == 0 ? tls_private_key.internal[0].public_key_openssh : var.tls_key.pubkey
}
