data "aws_iam_policy_document" "instance_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "${var.project}-${var.environment}-docker-host"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
}

resource "aws_iam_role_policy" "route53_acme" {
  name = "route53-acme"
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:GetChange",
          "route53:ChangeResourceRecordSets",
        ]
        Resource = [
          data.aws_route53_zone.domain.arn,
          "arn:aws:route53:::change/*",
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZones", "route53:ListHostedZonesByName", "route53:ListResourceRecordSets"]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecr" {
  count = var.ecr_registry_url != "" ? 1 : 0
  name  = "ecr"
  role  = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
        ]
        Resource = "arn:aws:ecr:${var.region}:*:repository/*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "walg" {
  name = "walg-s3"
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
        ]
        Resource = "${aws_s3_bucket.walg.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = aws_s3_bucket.walg.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "main" {
  name = "${var.project}-${var.environment}-docker-host"
  role = aws_iam_role.instance.name
}
