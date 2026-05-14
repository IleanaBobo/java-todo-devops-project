output "dev_public_ip" {
  value = aws_instance.dev_server.public_ip
}

output "prod_public_ip" {
  value = aws_instance.prod_server.public_ip
}
