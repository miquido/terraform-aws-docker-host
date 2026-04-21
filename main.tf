resource "random_password" "dynamic_user" {
  length  = 24
  special = false
}

module "docker_host" {
  source = "git::https://github.com/miquido/terraform-docker-host.git?ref=tags/1.0.3"

  domain                      = var.domain
  acme_email                  = var.acme_email
  dns_challenge_provider      = "route53"
  dns_challenge_env           = {
    AWS_REGION = var.region
  }
  oidc_jwks_url               = var.oidc_jwks_url
  oidc_audience               = var.oidc_audience
  oidc_expected_subs          = join(",", var.oidc_expected_subs)
  ip_allowlist                = var.ip_allowlist
  docker_compose_runner_image = var.docker_compose_runner_image
  passwd_hash                 = bcrypt(random_password.dynamic_user.result)
  registry_url                = var.ecr_registry_url
  use_ecr_credential_helper   = var.ecr_registry_url != ""
  block_device                = "/dev/xvdf"
}

resource "aws_security_group" "main" {
  name   = "${var.project}-${var.environment}-docker-host"
  vpc_id = data.aws_subnet.selected.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ip_range]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.main.id]
  iam_instance_profile   = aws_iam_instance_profile.main.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  dynamic "instance_market_options" {
    for_each = var.use_spot ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        instance_interruption_behavior = "stop"
        spot_instance_type             = "persistent"
      }
    }
  }

  user_data = module.docker_host.cloud_init_config

  tags = {
    Name        = "${var.project}-${var.environment}-docker-host"
    Project     = var.project
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [user_data, ami]
  }
}

resource "aws_eip" "main" {
  domain = "vpc"

  tags = {
    Name        = "${var.project}-${var.environment}-docker-host"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_eip_association" "main" {
  instance_id   = aws_instance.main.id
  allocation_id = aws_eip.main.id
}

resource "aws_ebs_volume" "data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = var.data_volume_size
  type              = "gp3"

  tags = {
    Name        = "${var.project}-${var.environment}-data"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.main.id
}
