output "public_ip" {
  description = "Elastic IP of the host: stable across restarts; the A records for <domain> and *.<domain> point to it."
  value       = module.docker_host.public_ip
}

output "nameservers" {
  description = "Delegate the domain to these (NS records in the parent zone) so the wildcard certificate can be issued."
  value       = aws_route53_zone.main.name_servers
}

output "registry_url" {
  value = module.docker_host.registry_url
}

output "registry_username" {
  value = module.docker_host.registry_username
}

output "registry_password" {
  value     = module.docker_host.registry_password
  sensitive = true
}

output "walg_backup_bucket" {
  value = module.docker_host.walg_backup_bucket
}
