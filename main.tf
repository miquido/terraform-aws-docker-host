locals {
  # Built-in registry: basic auth with generated credentials unless they are given. The host is
  # reachable from the internet, so the registry never runs without authentication here.
  registry_username = var.registry_username != "" ? var.registry_username : "ci"
  registry_password = var.enable_registry ? (var.registry_password != "" ? var.registry_password : random_password.registry[0].result) : ""
  registry_htpasswd = var.enable_registry ? (var.registry_htpasswd != "" ? var.registry_htpasswd : "${local.registry_username}:${bcrypt(local.registry_password)}") : ""

  cloudwatch_enabled = var.enable_metrics

  # Docker log driver: ship every container's stdout to CloudWatch Logs. Written before Docker
  # starts (cloud-init write_files runs ahead of runcmd), so no daemon restart is needed.
  docker_daemon_json = jsonencode({
    "log-driver" = "awslogs"
    "log-opts" = {
      "awslogs-region"       = var.region
      "awslogs-group"        = "/docker/${var.domain}"
      "awslogs-create-group" = "false"
      "tag"                  = "{{.Name}}"
    }
  })

  cloudwatch_write_files = [
    {
      path    = "/etc/docker/daemon.json"
      content = local.docker_daemon_json
    },
    {
      path    = "/etc/docker-host/cwagent-config.json"
      content = templatefile("${path.module}/templates/cloudwatch-agent-config.json.tftpl", { domain = var.domain })
    },
    {
      path    = "/etc/docker-host/prometheus.yaml"
      content = <<-EOT
        global:
          scrape_interval: 60s
          scrape_timeout: 10s
        scrape_configs:
          - job_name: traefik
            static_configs:
              - targets: ['traefik:8080']
            metrics_path: /metrics
      EOT
    },
  ]

  # Scrapes Traefik's Prometheus endpoint and ships it as CloudWatch EMF metrics.
  cloudwatch_agent_service = <<-EOT
    cloudwatch-agent:
      image: amazon/cloudwatch-agent:1.300073.0b1828
      environment:
        AWS_REGION: ${var.region}
      volumes:
        - /etc/docker-host/cwagent-config.json:/etc/cwagentconfig/cwagent-config.json:ro
        - /etc/docker-host/prometheus.yaml:/etc/cwagent/prometheus.yaml:ro
      restart: unless-stopped
      networks:
        - traefik-net
  EOT
}

module "docker_host" {
  source = "git::https://github.com/miquido/terraform-docker-host.git?ref=v2.0.0"

  vm_user      = "ubuntu"
  block_device = "/dev/xvdf"

  domain                 = var.domain
  acme_email             = var.acme_email
  dns_challenge_provider = "route53"
  dns_challenge_env = {
    AWS_REGION = var.region
  }
  oidc_jwks_url               = var.oidc_jwks_url
  oidc_audience               = var.oidc_audience
  oidc_expected_subs          = var.oidc_expected_subs
  ip_allowlist                = var.ip_allowlist
  docker_compose_runner_image = var.docker_compose_runner_image
  registry_url                = var.ecr_registry_url
  enable_registry             = var.enable_registry
  registry_htpasswd           = local.registry_htpasswd
  registry_username           = local.registry_username
  registry_password           = local.registry_password
  use_ecr_credential_helper   = var.ecr_registry_url != ""
  docker_prune_schedule       = var.docker_prune_schedule
  ssh_public_keys             = var.ssh_public_keys
  walg_env_vars = {
    AWS_REGION              = var.region
    WALG_COMPRESSION_METHOD = "lz4"
    PGHOST                  = "/var/run/postgresql"
  }

  enable_traefik_metrics = local.cloudwatch_enabled
  extra_write_files      = local.cloudwatch_enabled ? local.cloudwatch_write_files : []
  extra_compose_services = local.cloudwatch_enabled ? local.cloudwatch_agent_service : ""
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

  # gzip: the rendered cloud-init is larger than EC2's 16 KB user-data limit as plain text;
  # cloud-init unpacks gzip user data by itself.
  user_data_base64 = base64gzip(module.docker_host.cloud_init_config)

  tags = {
    Name        = "${var.project}-${var.environment}-docker-host"
    Project     = var.project
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [user_data, user_data_base64, ami]
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

resource "random_password" "registry" {
  count   = var.enable_registry && var.registry_password == "" ? 1 : 0
  length  = 32
  special = false
}
