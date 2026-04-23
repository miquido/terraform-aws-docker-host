resource "aws_s3_bucket" "walg" {
  bucket = "${var.project}-${var.environment}-walg-backups"

  tags = {
    Name        = "${var.project}-${var.environment}-walg-backups"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "walg" {
  bucket = aws_s3_bucket.walg.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "walg" {
  bucket = aws_s3_bucket.walg.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "walg" {
  bucket = aws_s3_bucket.walg.id

  rule {
    id     = "expire-old-backups"
    status = "Enabled"

    expiration {
      days = var.walg_backup_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}