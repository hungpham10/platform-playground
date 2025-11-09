output "postgres" {
  value = local.postgres_inventory
}

output "gateway" {
  value = module.gateway-inventory.inventory
}
