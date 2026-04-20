output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.main.public_ip
}

output "domain" {
  description = "Base domain"
  value       = var.domain
}
