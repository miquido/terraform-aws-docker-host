output "public_ip" {
  description = "Elastic IP address of the instance"
  value       = aws_eip.main.public_ip
}

output "domain" {
  description = "Base domain"
  value       = var.domain
}

output "walg_backup_bucket" {
  description = "S3 bucket name for WAL-G backups"
  value       = aws_s3_bucket.walg.bucket
}

output "registry_url" {
  description = "Hostname of the built-in registry (empty when enable_registry is false)"
  value       = var.enable_registry ? "registry.${var.domain}" : ""
}

output "registry_username" {
  description = "User of the built-in registry"
  value       = var.enable_registry ? local.registry_username : ""
}

output "registry_password" {
  description = "Password of the built-in registry (generated unless registry_password was given)"
  value       = local.registry_password
  sensitive   = true
}

output "data_volume_id" {
  description = "ID of the EBS data volume"
  value       = aws_ebs_volume.data.id
}

output "walg_replication_role_arn" {
  description = "ARN of the role that replicates the WAL-G bucket (null when replication is off); the destination bucket must allow it"
  value       = one(aws_iam_role.walg_replication[*].arn)
}
