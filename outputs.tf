output "public_ip" {
  description = "Elastic IP address of the instance"
  value       = aws_eip.main.public_ip
}

output "domain" {
  description = "Base domain"
  value       = var.domain
}
