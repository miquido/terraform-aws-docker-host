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
