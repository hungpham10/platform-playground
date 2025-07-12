output "vpc" {
  value = module.vpc.id
}

output "public-subnet" {
  value = module.public-subnet.id
}
