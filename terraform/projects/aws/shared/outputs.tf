output "vpc" {
  value = module.vpc.id
}

output "public-subnets" {
  value = module.public-subnet.id_array
}
