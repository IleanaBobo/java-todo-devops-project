output "dev_public_ip" {
value = aws_eip.dev_eip.public_ip
}

output "prod_public_ip" {
value = aws_eip.prod_eip.public_ip
}

