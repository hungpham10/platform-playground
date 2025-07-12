output "id_array" {
  value = aws_subnet.this[*].id
}
