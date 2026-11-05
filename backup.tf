# Daily snapshots of the data volume (compose files, certificates, bind-mounted application data and
# database files). They are crash-consistent: a database on it recovers like after a power cut. Keep
# a logical or WAL-based backup (WAL-G) for the database itself; this is the safety net for
# everything else on the volume and for a quick whole-host restore.
resource "aws_iam_role" "dlm" {
  count = var.enable_ebs_snapshots ? 1 : 0

  name               = "${var.project}-${var.environment}-docker-host-dlm"
  assume_role_policy = data.aws_iam_policy_document.dlm_assume_role[0].json
}

data "aws_iam_policy_document" "dlm_assume_role" {
  count = var.enable_ebs_snapshots ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "dlm" {
  count = var.enable_ebs_snapshots ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:DeleteSnapshot",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*::snapshot/*"]
  }
}

resource "aws_iam_role_policy" "dlm" {
  count = var.enable_ebs_snapshots ? 1 : 0

  name   = "dlm-lifecycle"
  role   = aws_iam_role.dlm[0].id
  policy = data.aws_iam_policy_document.dlm[0].json
}

resource "aws_dlm_lifecycle_policy" "data" {
  count = var.enable_ebs_snapshots ? 1 : 0

  description        = "${var.project}-${var.environment} docker host data volume snapshots"
  execution_role_arn = aws_iam_role.dlm[0].arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "daily"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = [var.ebs_snapshot_time]
      }

      retain_rule {
        count = var.ebs_snapshot_retention_count
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      # Carries the volume's Name/Project/Environment tags over, so a snapshot can be found by name.
      copy_tags = true
    }

    target_tags = {
      DockerHostBackup = "${var.project}-${var.environment}"
    }
  }
}
