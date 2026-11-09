# One-way replication of the WAL-G bucket into a bucket in another account (see the replica-bucket module of
# miquido/devops/devops-vault-infrastructure). Off unless walg_replication_destination_bucket_arn is set.
#
# - Deletions at the source are not replicated (no delete marker replication, no s3:ReplicateDelete): a wiped or
#   lifecycle-expired source does not touch the replica.
# - Only objects written after the rule exists are replicated. A base backup taken afterwards makes the replica
#   self-sufficient (that backup plus the WAL after it), so existing objects need no one-off copy.
locals {
  walg_replication_enabled   = var.walg_replication_destination_bucket_arn != null
  walg_replication_role_name = "${var.project}-${var.environment}-walg-replication"
}

resource "aws_iam_role" "walg_replication" {
  count = local.walg_replication_enabled ? 1 : 0

  name = local.walg_replication_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "walg_replication" {
  count = local.walg_replication_enabled ? 1 : 0

  statement {
    actions   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
    resources = [aws_s3_bucket.walg.arn]
  }

  statement {
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    resources = ["${aws_s3_bucket.walg.arn}/*"]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner",
    ]
    resources = ["${var.walg_replication_destination_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "walg_replication" {
  count = local.walg_replication_enabled ? 1 : 0

  name   = "replicate-walg-bucket"
  role   = aws_iam_role.walg_replication[0].id
  policy = data.aws_iam_policy_document.walg_replication[0].json
}

resource "aws_s3_bucket_replication_configuration" "walg" {
  count = local.walg_replication_enabled ? 1 : 0

  bucket = aws_s3_bucket.walg.id
  role   = aws_iam_role.walg_replication[0].arn

  rule {
    id       = "to-backup-vault"
    status   = "Enabled"
    priority = 1

    filter {}

    delete_marker_replication {
      status = "Disabled"
    }

    destination {
      bucket = var.walg_replication_destination_bucket_arn
    }
  }

  # Replication needs a versioned source and the role's policy in place before S3 validates the rule.
  depends_on = [
    aws_s3_bucket_versioning.walg,
    aws_iam_role_policy.walg_replication,
  ]

  lifecycle {
    precondition {
      condition     = var.walg_bucket_versioning
      error_message = "Replication needs walg_bucket_versioning = true."
    }
  }
}
