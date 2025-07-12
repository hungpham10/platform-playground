output "id" {
  description = "The VPC id"
  value       = var.flags.is_mocking? data.aws_vpc.this[0].id : aws_vpc.this[0].id
}
