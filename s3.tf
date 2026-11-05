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

# Versioning is the safety net that does not depend on the client: if a database started from an old
# data directory (a volume restored from a snapshot) or a misconfigured clone overwrites WAL-G objects,
# the previous versions are still there. WAL-G's own WALG_PREVENT_WAL_OVERWRITE is the first line.
resource "aws_s3_bucket_versioning" "walg" {
  bucket = aws_s3_bucket.walg.id

  versioning_configuration {
    status = var.walg_bucket_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "walg" {
  bucket = aws_s3_bucket.walg.id

  # The lifecycle configuration must follow versioning, or noncurrent-version rules are rejected.
  depends_on = [aws_s3_bucket_versioning.walg]

  rule {
    id     = "expire-old-backups"
    status = "Enabled"

    expiration {
      days = var.walg_backup_retention_days
    }

    # With versioning on, expiring and `wal-g delete` leave delete markers and noncurrent versions;
    # this is how long those are kept (the window to recover an overwritten or deleted object).
    noncurrent_version_expiration {
      noncurrent_days = var.walg_noncurrent_version_retention_days
    }
  }

  # Delete markers whose versions are all gone would otherwise stay forever.
  rule {
    id     = "clean-up-delete-markers"
    status = "Enabled"

    filter {}

    expiration {
      expired_object_delete_marker = true
    }
  }
}